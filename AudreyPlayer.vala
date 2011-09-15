using Gtk;
using Gst;

public class PlayPauseButton : Button {
    
    private Image img_play;
    private Image img_pause;
    
    public bool playing;
    
    public PlayPauseButton() {
        img_play = new Image.from_stock(Stock.MEDIA_PLAY, IconSize.BUTTON);
        img_pause = new Image.from_stock(Stock.MEDIA_PAUSE, IconSize.BUTTON);
        set_playing(false);
    }
    
    public void set_playing(bool playing) {
        image = playing?img_pause:img_play;
        this.playing = playing;
    }
    
}

public class FullscreenButton : Button {
    
    private Image img_fullscreen;
    private Image img_unfullscreen;
    
    public bool fullscreen;
    
    public FullscreenButton() {
        img_fullscreen = new Image.from_stock(Stock.FULLSCREEN, IconSize.BUTTON);
        img_unfullscreen = new Image.from_stock(Stock.LEAVE_FULLSCREEN, IconSize.BUTTON);
        set_fullscreen(false);
    }
    
    public void set_fullscreen(bool fullscreen) {
        image = fullscreen?img_unfullscreen:img_fullscreen;
        this.fullscreen = fullscreen;
    }
    
}

public class AudreyPlayer : VBox {
    
    private Box box;
    
    private Scale scale;
    private AspectFrame aspect_frame;
    private DrawingArea drawing_area;
    
    private Pipeline pipeline;
    private Element playbin;
    
    private Element audio;
    private Element video;
    
    private PlayPauseButton btn_play;
    private VolumeButton btn_volu;
    private FullscreenButton btn_full;
    private Button btn_sett;
    
    private bool scale_my_changed = false;
    
    public AudreyPlayer() {
        
        box = new Box(Orientation.HORIZONTAL, 0);
        
        drawing_area = new DrawingArea();
        drawing_area.set_size_request(640, 360);
        drawing_area.realize.connect(embed_video);
        
        aspect_frame = new AspectFrame("", (float) 0.5, (float) 0.5, 16/9, true);
        aspect_frame.set_shadow_type(ShadowType.NONE);
        aspect_frame.add(drawing_area);
        
        pack_start(aspect_frame, true, true, 0);
        pack_start(box, false, true, 0);
        
        setup_gtk_controlls();
        setup_gst_pipeline();
        
        show_all();
        
    }
    
    private void setup_gtk_controlls() {
        
        scale = new Scale(Orientation.HORIZONTAL, new Adjustment(0, 0, 100, 0.1, 1, 1));
        scale.draw_value = false;
        
        btn_play = new PlayPauseButton();
        btn_volu = new VolumeButton();
        btn_full = new FullscreenButton();
        btn_sett = new Button();
        
        btn_sett.image = new Image.from_stock(Stock.PROPERTIES, IconSize.BUTTON);
        
        btn_play.relief = ReliefStyle.NONE;
        btn_volu.relief = ReliefStyle.NONE;
        btn_full.relief = ReliefStyle.NONE;
        btn_sett.relief = ReliefStyle.NONE;
        
        box.pack_start(btn_play, false, true, 0);
        box.pack_start(this.scale, true, true, 0);
        box.pack_start(btn_volu, false, true, 0);
        box.pack_start(btn_full, false, true, 0);
        box.pack_start(btn_sett, false, true, 0);
        
        btn_volu.set_value(1.0);
        
        btn_play.clicked.connect(play);
        btn_volu.value_changed.connect(on_volu);
        btn_full.clicked.connect(on_full);
        btn_sett.clicked.connect(on_sett);
        scale.value_changed.connect(scale_changed);
        
    }
    
    private void setup_gst_pipeline () {
        
        pipeline = new Pipeline("audrey");
        
        playbin = ElementFactory.make("playbin2", "playbin");
        video = ElementFactory.make("xvimagesink", "video");
        audio = ElementFactory.make("autoaudiosink", "audio");
        
        pipeline.add(this.playbin);
        
        playbin.set("video-sink", this.video);
        playbin.set("audio-sink", this.audio);
        
    }
    
    private void on_volu(double value) {
        playbin.set("volume", value);
    }
    
    private void on_full() {
        Window win = get_parent() as Window;
        btn_full.set_fullscreen(!btn_full.fullscreen);
        if(btn_full.fullscreen) { win.fullscreen(); }
        else { win.unfullscreen(); }
    }
    
    private void on_sett() {
        (get_parent() as Audrey).show_welcome();
    }
    
    private void scale_changed() {
        
        if(scale_my_changed) {
            scale_my_changed = false;
            return ;
        }
        
        if(!btn_play.playing) {
            return ;
        }
        
        Format fmt = Format.BYTES;
        int64 duration;
        
        if(!playbin.query_duration(ref fmt, out duration)) {
            return ;
        }
        
        playbin.seek_simple(fmt, SeekFlags.FLUSH, (int64) (((float) scale.adjustment.value / 100) * duration));
        
    }
    
    private float scale_pos() {
        
        Format fmt = Format.BYTES;
        
        int64 position;
        int64 duration;
        
        if(!playbin.query_position(ref fmt, out position)) {
            return 0;
        }
        
        if(!playbin.query_duration(ref fmt, out duration)) {
            return 0;
        }
        
        return (((float) position / (float) duration) * 100);
    }
    
    private bool scale_update() {
        
        if(!btn_play.playing) {
            return false;
        }
        
        scale_my_changed = true;
        scale.adjustment.value = scale_pos();
        
        return true;
    }
    
    private void embed_video() {
        var xoverlay = video as XOverlay;
        xoverlay.set_xwindow_id(Gdk.X11Window.get_xid(drawing_area.get_window()));
    }
    
    public void set_uri(string uri) {
        stop();
        playbin.set("uri", uri);
        play();
    }
    
    public void play() {
        
        if(btn_play.playing) {
            pipeline.set_state(State.PAUSED);
        } else {
            
            if(drawing_area.get_realized()) {
                embed_video();
            }
            
            pipeline.set_state(State.PLAYING);
            Timeout.add(250, scale_update);
            
        }
        
        btn_play.set_playing(!btn_play.playing);
        
    }
    
    public void stop() {
        pipeline.set_state(State.READY);
        btn_play.set_playing(false);
    }
    
}
