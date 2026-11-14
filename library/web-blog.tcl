# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Load the blog package and its storage dependencies.
package require Tcl 8.6 9
package require tpersist 0.1.4
package require cmark_gfm 0.1.0
package require tpathexp 1.1.0
package require jinja2 0.1.0
package require tjson 1.0.26

namespace eval ::web::blog {
    variable root [file dirname [file dirname [info script]]]
    namespace import ::tpersist::db_*
}
source [file join $::web::blog::root library content.tcl]
source [file join $::web::blog::root library initdb.tcl]
source [file join $::web::blog::root library templates.tcl]
source [file join $::web::blog::root library http.tcl]
source [file join $::web::blog::root library mount.tcl]
package provide web-blog 0.1.4
