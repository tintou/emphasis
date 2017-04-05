project('com.github.tintou.emphasis', 'c', 'vala', version: '0.1.0')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'vapi')],
                      language: 'vala')
add_project_arguments(['-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name())],
                      language: 'c')

i18n = import('i18n')

gobject_dep = dependency ('gobject-2.0', version: '>=2.44')
glib_dep = dependency ('glib-2.0', version: '>=2.44')
gio_dep = dependency ('gio-2.0', version: '>=2.44')
gee_dep = dependency ('gee-0.8')
gtk_dep = dependency ('gtk+-3.0')
gstreamer_dep = dependency ('gstreamer-1.0')
gstreamer_base_dep = dependency ('gstreamer-base-1.0')
gstreamer_pbutils_dep = dependency ('gstreamer-pbutils-1.0')
gstreamer_video_dep = dependency ('gstreamer-video-1.0')
gstreamer_editing_services_dep = dependency ('gst-editing-services-1.0')
posix_dep = meson.get_compiler('vala').find_library('posix')
libm_dep = meson.get_compiler('c').find_library('m', required: false)

subdir('src')
