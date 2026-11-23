# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Register the package and load its dependencies.
if {![package vsatisfies [package provide Tcl] 8.6-10]} {return}
package ifneeded web-blog 1.0.0 [list source [file join $dir library web-blog.tcl]]

# Locate the manifest without loading application services.
package ifneeded web-blog::manifest 1.0.0 [list apply {{dir} {
    package require web-core 0.1.0
    ::web::core::register web-blog $dir
    package provide web-blog::manifest 1.0.0
}} $dir]
