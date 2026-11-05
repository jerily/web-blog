if {![package vsatisfies [package provide Tcl] 8.6-10]} {return}
package ifneeded web-blog 0.1.0 [list source [file join $dir library web-blog.tcl]]
