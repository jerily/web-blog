package require web-wiki 0.1.0
namespace eval ::web::blog {}
source [file join [file dirname [info script]] mount.tcl]
package provide web-blog 0.1.0
