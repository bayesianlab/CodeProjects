#include <gtk/gtk.h>

static void on_activate(GtkApplication *app) {
  GtkWidget *window = gtk_application_window_new(app);
  GtkWidget *button = gtk_button_new_with_label("Click");
  gtk_window_set_title(GTK_WINDOW(window), "Dillons App");
  g_signal_connect_swapped(button, "clicked", G_CALLBACK(gtk_widget_destroy),
                           window);
  

  gtk_container_add(GTK_CONTAINER(window), button);
  gtk_widget_show_all(window);
}

int main(int argc, char *argv[]) {
  GtkApplication *app = gtk_application_new("com.example.GtkApplication",
                                            G_APPLICATION_FLAGS_NONE);
  g_signal_connect(app, "activate", G_CALLBACK(on_activate), NULL);
  return g_application_run(G_APPLICATION(app), argc, argv);
  printf("Hello\n");
  return 0;
}
