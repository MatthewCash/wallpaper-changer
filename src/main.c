#include <glib.h>
#include <gio/gio.h>
#include <fcntl.h>
#include <sys/sendfile.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/stat.h>

int main(int argc, char *argv[])
{
    // Get destination path from env

    char* static_wallpaper_path = getenv("STATIC_WALLPAPER_PATH");
    if (static_wallpaper_path == NULL) {
        fprintf(stderr, "Variable $STATIC_WALLPAPER_PATH is missing!\n");
        exit(1);
    }

    // Get source path from args

    char path[4096] = { 0 }; // Maximum path length

    for (int i = 1; i < argc; i++) {
        strncat(path, argv[i], 4096);
    }

    // Get file size

    struct stat st;
    stat(path, &st);
    size_t size = st.st_size;

    printf("Copying wallpaper from '%s'\n", path);

    // Copy Wallpaper

    int source_fd = open(path, O_RDONLY);
    if (source_fd < 0) {
        perror("Could not open source file");
        exit(1);
    }

    int dest_fd = open(static_wallpaper_path, O_RDWR | O_CREAT, S_IRUSR | S_IWUSR);
    if (dest_fd < 0) {
        perror("Could not open destination file");
        exit(1);
    }

    if (sendfile(dest_fd, source_fd, NULL, size) < 0) {
        perror("Failed to copy wallpaper!");
        exit(1);
    }

    // Refresh Wallpaper

    GSettings *settings = g_settings_new("org.gnome.desktop.background");
    
    char picture_uri_path[4096] = "file://";
    strcat(picture_uri_path, static_wallpaper_path);

    g_settings_set_string(settings, "picture-uri", static_wallpaper_path);
    g_settings_set_string(settings, "picture-uri-dark", static_wallpaper_path);

    g_settings_sync();
}
