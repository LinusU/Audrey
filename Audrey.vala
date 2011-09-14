using Gtk;

public class Audrey : Window {
    
    private AudreyWelcome welcome;
    private AudreyPlayer player;
    
    private int mode = 0;
    
    const TargetEntry[] targets = {
        { "text/uri-list", 0, 0}
    };
    
    public Audrey(string ?uri) {
        
        set_title("Audrey");
        set_default_size(800, 450);
        
        drag_dest_set(this, DestDefaults.ALL, targets, Gdk.DragAction.COPY);
        drag_data_received.connect(on_drag_data_received);
        
        destroy.connect(Gtk.main_quit);
        
        if(uri == null) {
            show_welcome();
        } else {
            show_player(uri);
        }
        
        show();
        
    }
    
    public void show_welcome() {
        
        if(welcome == null) {
            welcome = new AudreyWelcome();
        }
        
        if(mode == 2) {
            player.stop();
            remove(player);
        }
        
        if(mode != 1) {
            add(welcome);
        }
        
        mode = 1;
        
    }
    
    public void show_player(string uri) {
        
        if(player == null) {
            player = new AudreyPlayer();
        }
        
        if(mode == 1) {
            remove(welcome);
        }
        
        if(mode != 2) {
            add(player);
        }
        
        mode = 2;
        player.set_uri(uri);
        
    }
    
    private void on_drag_data_received(Widget sender, Gdk.DragContext context, int x, int y, SelectionData selection_data, uint info, uint time_) {
        
        string[] uris = selection_data.get_uris();
        
        if(uris.length > 0) {
            show_player(uris[0]);
        }
        
    }
    
    public static int main(string[] args) {
        
        Gst.init(ref args);
        Gtk.init(ref args);
        
        if(args.length > 1) {
            new Audrey(args[1]);
        } else {
            new Audrey(null);
        }
        
        Gtk.main();
        
        return 0;
    }
}
