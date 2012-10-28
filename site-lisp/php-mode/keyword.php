<?php
/**
 * $Id: keyword.php 747 2007-03-11 17:19:23Z torihat $
 *
 * xyzzyのキーワードファイルを出力する
 *
 * by Masashi Hattori
 *
 * [Usage: php -q keyword.php]
 */
?>
;*0b
function
class
var
public
protected
private
const
static
final
abstract
interface
implements
__construct
__destruct
__set
__get
__isset
__unset
__call
__sleep
__wakeup
__set_state
__clone
__autoload
;*0
new
if
else
elseif
do
while
for
break
continue
switch
case
require
require_once
include
include_once
return
extends
foreach
declare
iterator
;*0u
string
array
object
boolean
integer
float
double
resource
;*1b
GLOBALS
_SERVER
HTTP_SERVER_VARS
_GET
HTTP_GET_VARS
_POST
HTTP_POST_VARS
_COOKIE
HTTP_COOKIE_VARS
_FILES
HTTP_POST_FILES
_ENV
HTTP_ENV_VARS
_REQUEST
_SESSION
HTTP_SESSION_VARS
__LINE__
__FILE__
;*1
<?php
// CONSTANTS
$constants = get_defined_constants();
if($constants){
  foreach($constants as $k => $v){
    printf("%s\n", $k);
  }
}
?>
;*2
<?php
// FUNCTIONS
$funcs = get_defined_functions();
if($funcs && $funcs["internal"]){
  foreach($funcs["internal"] as $k => $v){
    printf("%s\n", $v);
  }
}
?>
