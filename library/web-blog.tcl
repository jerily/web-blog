# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Load the blog package and its storage dependencies.
package require web-blog::manifest
package require Tcl
package require tpersist
package require cmark_gfm
package require tpathexp
package require jinja2
package require tjson

namespace eval ::web::blog {
    variable root [file dirname [file dirname [info script]]]
    namespace import ::tpersist::db_*
}
source [file join $::web::blog::root library content.tcl]
source [file join $::web::blog::root library initdb.tcl]
source [file join $::web::blog::root library templates.tcl]
source [file join $::web::blog::root library http.tcl]
source [file join $::web::blog::root library mount.tcl]
package provide web-blog 1.0.0
