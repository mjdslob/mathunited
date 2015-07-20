package nl.math4all.gae_m4a.configuration;

public class SubComponent {
    public String title;
    public String file;
    public String id;
    public String number;

    public SubComponent(String id, String title, String file, String number) {
        this.title = title;
        this.file = file;
        this.id = id; 
        this.number = number;
    }
}
