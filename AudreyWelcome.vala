using Gtk;

public class OpenFileDialog : FileChooserDialog {
    
    public OpenFileDialog() {
        
        title = "Open File";
        action = FileChooserAction.OPEN;
        
        add_button(Stock.CANCEL, ResponseType.CANCEL);
        add_button(Stock.OPEN, ResponseType.ACCEPT);
        set_default_response(ResponseType.ACCEPT);
        
    }
    
}

public class AudreyWelcome : Fixed {
    
    private Box box;
    
    private Button btn_file;
    private Button btn_disc;
    private Button btn_ejec;
    
    private OpenFileDialog ofd;
    
    public AudreyWelcome() {
        
        box = new Box(Orientation.HORIZONTAL, 12);
        
        btn_file = new Button();
        btn_disc = new Button();
        btn_ejec = new Button();
        
        Box b;
        
        b = new Box(Orientation.VERTICAL, 0);
        b.pack_start(new Image.from_stock(Stock.OPEN, IconSize.DIALOG));
        b.pack_start(new Label("Open File"));
        btn_file.add(b);
        
        b = new Box(Orientation.VERTICAL, 0);
        b.pack_start(new Image.from_stock(Stock.CDROM, IconSize.DIALOG));
        b.pack_start(new Label("Open Disc"));
        btn_disc.add(b);
        
        b = new Box(Orientation.VERTICAL, 0);
        b.pack_start(new Image.from_stock("gtk-media-eject", IconSize.DIALOG));
        b.pack_start(new Label("Eject Media"));
        btn_ejec.add(b);
        
        put(btn_file, 0, 0);
        put(btn_disc, 0, 0);
        put(btn_ejec, 0, 0);
        
        set_size_request(480, 180);
        
        btn_file.set_size_request(128, 180);
        btn_disc.set_size_request(128, 180);
        btn_ejec.set_size_request(128, 180);
        
        btn_file.clicked.connect(on_file);
        btn_disc.clicked.connect(on_disc);
        btn_ejec.clicked.connect(on_ejec);
        
        size_allocate.connect(resized);
        //check_resize.connect(resized);
        
        show_all();
        
    }
    
    private void resized(Allocation allocation) {
        
        int startx = (int) ((get_allocated_width() - 480) / 2);
        int starty = (int) ((get_allocated_height() - 180) / 2);
        
        move(btn_file, startx +   0, starty + 0);
        move(btn_disc, startx + 176, starty + 0);
        move(btn_ejec, startx + 352, starty + 0);
        
        //queue_draw();
        //queue_resize();
        
        //resize_children();
        
    }
    
    private void play(string uri) {
        Audrey app = get_parent() as Audrey;
        app.show_player(uri);
    }
    
    private void on_file() {
        
        if(ofd == null) {
            ofd = new OpenFileDialog();
        }
        
        if(ofd.run() == ResponseType.ACCEPT) {
            play(ofd.get_uri());
        }
        
        ofd.hide();
        
    }
    
    private void on_disc() {
        play("dvd://");
    }
    
    private void on_ejec() {
        //FIXME
    }
    
}
