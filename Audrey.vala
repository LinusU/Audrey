using Gtk;
using Gst;
using GLib;

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

public class Audrey : Window {
    
    private Box vbox;
    private Box hbox;
    
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
    
    const TargetEntry[] targets = {
        { "text/uri-list", 0, 0}
    };
    
    public Audrey() {
        
        vbox = new Box(Orientation.VERTICAL, 0);
        hbox = new Box(Orientation.HORIZONTAL, 0);
        
        scale = new Scale(Orientation.HORIZONTAL, new Adjustment(0, 0, 100, 0.1, 1, 1));
        scale.draw_value = false;
        
        drawing_area = new DrawingArea();
        drawing_area.set_size_request(640, 360);
        
        aspect_frame = new AspectFrame("", (float) 0.5, (float) 0.5, 16/9, true);
        aspect_frame.set_shadow_type(ShadowType.NONE);
        aspect_frame.add(drawing_area);
        
        vbox.pack_start(aspect_frame, true, true, 0);
        vbox.pack_start(hbox, false, true, 0);
        
        Gdk.Color bg;
        Gdk.Color.parse("black", out bg);
        
        modify_bg(StateType.NORMAL, bg);
        
        add(vbox);
        
        setup_gtk_controlls();
        setup_gst_pipeline();
        
        drag_dest_set(this, DestDefaults.ALL, targets, Gdk.DragAction.COPY);
        drag_data_received.connect(on_drag_data_received);
        
    }
    
    public void set_uri(string uri) {
        this.playbin.set("uri", uri);
    }
    
    private void setup_gtk_controlls() {
        
        btn_play = new PlayPauseButton();
        btn_volu = new VolumeButton();
        btn_full = new FullscreenButton();
        btn_sett = new Button();
        
        btn_sett.image = new Image.from_stock(Stock.PROPERTIES, IconSize.BUTTON);
        
        btn_play.relief = ReliefStyle.NONE;
        btn_volu.relief = ReliefStyle.NONE;
        btn_full.relief = ReliefStyle.NONE;
        btn_sett.relief = ReliefStyle.NONE;
        
        hbox.pack_start(btn_play, false, true, 0);
        hbox.pack_start(this.scale, true, true, 0);
        hbox.pack_start(btn_volu, false, true, 0);
        hbox.pack_start(btn_full, false, true, 0);
        hbox.pack_start(btn_sett, false, true, 0);
        
        btn_volu.set_value(1.0);
        
        btn_play.clicked.connect(play);
        btn_volu.value_changed.connect(on_volu);
        btn_full.clicked.connect(on_full);
        
        show_all();
        
    }
    
    private void setup_gst_pipeline () {
        
        this.pipeline = new Pipeline("audrey");
        
        this.playbin = ElementFactory.make("playbin2", "playbin");
        this.video = ElementFactory.make("xvimagesink", "video");
        this.audio = ElementFactory.make("autoaudiosink", "audio");
        
        this.pipeline.add(this.playbin);
        
        this.playbin.set("video-sink", this.video);
        this.playbin.set("audio-sink", this.audio);
        
    }

    private void play() {
        
        if(btn_play.playing) {
            this.pipeline.set_state(State.PAUSED);
        } else {
            var xoverlay = this.video as XOverlay;
            xoverlay.set_xwindow_id(Gdk.X11Window.get_xid(this.drawing_area.get_window()));
            this.pipeline.set_state(State.PLAYING);
        }
        
        btn_play.set_playing(!btn_play.playing);
        
    }
    
    private void on_volu(double value) {
        this.playbin.set("volume", value);
    }
    
    private void on_full() {
        btn_full.set_fullscreen(!btn_full.fullscreen);
        if(btn_full.fullscreen) { fullscreen(); }
        else { unfullscreen(); }
    }
    
    private void on_drag_data_received(Widget sender, Gdk.DragContext context, int x, int y, SelectionData selection_data, uint info, uint time_) {
        
        string[] uris = selection_data.get_uris();
        
        if(uris.length > 0) {
            stop();
            set_uri(uris[0]);
            play();
        }
        
    }
    
    private void stop() {
        this.pipeline.set_state(State.READY);
        btn_play.set_playing(false);
    }
    
    public static int main (string[] args) {
        
        Gst.init(ref args);
        Gtk.init(ref args);
        
        var audrey = new Audrey();
        
        if(args.length > 1) {
            audrey.set_uri(args[1]);
            audrey.play();
        }
        
        Gtk.main();
        
        return 0;
    }
}
