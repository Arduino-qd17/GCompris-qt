/* GCompris - ActivityInfo.qml
 *
 * Copyright (C) 2015 Bruno Coudoin <bruno.coudoin@gcompris.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
import GCompris 1.0

ActivityInfo {
  name: "scalesboard/ScaleNumber.qml"
  difficulty: 2
  icon: "scalesboard/scalesboard.svg"
  author: "Bruno Coudoin &lt;bruno.coudoin@gcompris.net&gt;"
  demo: false
  //: Activity title
  title: qsTr("Balance the scales properly")
  //: Help title
  description: qsTr("Drag and Drop weights to balance the scales")
//  intro: "Drag the weights up to balance the scales."
  //: Help goal
  goal: qsTr("Mental calculation, arithmetic equality")
  //: Help prerequisite
  prerequisite: ""
  //: Help manual
  manual: qsTr("To balance the scales, move the weights to the left or the right side (on higher levels). The weights can be arranged in any order.")
  credit:""
  section: "math"
  createdInVersion: 0
}
