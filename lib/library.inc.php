<?php
function dbconnect() {
        $mysqli = new mysqli ("localhost","DBUSERNAME","DBPASSWORD","autodoc");
        // Check connection
        if ($mysqli->connect_errno)
        {
                echo ex_error("Failed to connect to MySQL: " . mysqli_connect_error());
                return false;
        }
        $mysqli->query("SET NAMES UTF8");
        return $mysqli;
}

function get_response($URL, $context)
{
        if(!function_exists('curl_init')) {
        die ("Curl PHP package not installedn");
        }

        /*Initializing CURL*/
        $curlHandle = curl_init();

        /*The URL to be downloaded is set*/
        curl_setopt($curlHandle, CURLOPT_URL, $URL);
        curl_setopt($curlHandle, CURLOPT_HEADER, false);
        curl_setopt($curlHandle, CURLOPT_HTTPHEADER, array("Content-Type: text/xml"));
        curl_setopt($curlHandle, CURLOPT_POSTFIELDS, $context);
        curl_setopt($curlHandle, CURLOPT_RETURNTRANSFER, true);

        /*Now execute the CURL, download the URL specified*/
        $response = curl_exec($curlHandle);
        return $response;
}

function get_post_id($ip) {
        global $mysqli;

        $longip = ip2long($ip);

        $sql="SELECT post_id FROM autodoc_ip WHERE ipv4=$longip";

        if ($result = $mysqli->query($sql)) {
                if($obj = $result->fetch_object()) {
                        return $obj->post_id;
                }
        }
return false;
}

function add_relation_post_ip($ip,$post_id)
{
        global $mysqli;
        $longip = ip2long($ip);
        $sql="INSERT INTO `autodoc_ip` (`ipv4`, `post_id`) VALUES ('$longip', '$post_id');";

        if ($mysqli->query($sql)) {
                return true;
        } else {
                return false;
        }
}

?>
