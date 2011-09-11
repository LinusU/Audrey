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

public class Audrey : Window {
    
    private Box vbox;
    private Box hbox;
    
    private Scale scale;
    private DrawingArea drawing_area;
    
    private Pipeline pipeline;
    private Element playbin;
    
    private Element audio;
    private Element video;
    
    private PlayPauseButton btn_play;
    private VolumeButton btn_volu;
    private FullscreenButton btn_full;
    private Button btn_sett;

    public Audrey() {
        
        this.vbox = new Box(Orientation.VERTICAL, 0);
        this.hbox = new Box(Orientation.HORIZONTAL, 0);
        
        this.scale = new Scale(Orientation.HORIZONTAL, new Adjustment(0, 0, 100, 0.1, 1, 1));
        this.scale.draw_value = false;
        
        this.drawing_area = new DrawingArea();
        this.drawing_area.set_size_request(640, 360);
        
        vbox.pack_start(this.drawing_area, true, true, 0);
        vbox.pack_start(hbox, false, true, 0);
        
        controlls();
        
        Gdk.Color bg;
        Gdk.Color.parse("black", out bg);
        
        this.modify_bg(StateType.NORMAL, bg);
        
        add(vbox);
        
        setup_gst_pipeline();
        
    }
    
    public void set_uri(string uri) {
        this.playbin.set("uri", uri);
    }
    
    private void controlls() {
        
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
        
        btn_play.clicked.connect(on_play);
        btn_volu.value_changed.connect(on_volu);
        btn_full.clicked.connect(on_full);
        
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

    private void on_play() {
        
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
    
    private void stop() {
        this.pipeline.set_state(State.READY);
    }
    
    public static int main (string[] args) {
        
        Gst.init(ref args);
        Gtk.init(ref args);
        
        var audrey = new Audrey();
        
        audrey.set_uri("file:///home/linus/Videos/Source Code (2011) DVDRip XviD-MAXSPEED www.torentz.3xforum.ro.avi");
        audrey.show_all();
        
        Gtk.main();
        
        return 0;
    }
}
