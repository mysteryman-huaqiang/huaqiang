#!/bin/sh


if [ ! -d "tmp" ]; then
  mkdir tmp
fi


function format_json(){
    key=`echo $1|awk -F'/' '{print $NF}'`
    if [ $# -eq 1 ];then
      awk -F: 'BEGIN{while((getline t < ARGV[1]) > 0)last++;close(ARGV[1])}{print "\""$1"\":\""$2"\"", ((last==FNR)?"":",")}END{print "},"}'  $1|awk -v awk_var="$key" 'BEGIN{print "\"",awk_var,"\":{"}{print $0}'
    elif [ $# -eq 2 ];then
      awk -F: 'BEGIN{while((getline t < ARGV[1]) > 0)last++;close(ARGV[1])}{print "\""$1"\":\""$2"\"", ((last==FNR)?"":",")}END{print "}"}'  $1|awk -v awk_var="$key" 'BEGIN{print "\"",awk_var,"\":{"}{print $0}'
    else
      echo "function format_json error"
    fi
}


function get_system_info(){
    
    tmpdir=tmp/
    #start
    echo \"system\":{
    #put the k:v to buffer.txt ,many more
    esxcli hardware cpu global get |grep -i "CPU" > $tmpdir/PHYSICAL_INFO
    vmware -v |grep -i  "VMware ESXi" |awk '{print "esxi_version:"$3}' > $tmpdir/RELEASE
    hostname -f |awk '{print "esxi_hostname:"$1}' > $tmpdir/HOSTNAME
    esxcfg-vmknic -l  |grep -i  "IPV4" |awk '{print "IP:"$5}' > $tmpdir/IP
    esxcfg-route  |grep -i  "VMkernel" |awk '{print "ROUTE:"$5}' > $tmpdir/ROUTE


    #to json
    format_json $tmpdir/PHYSICAL_INFO
    format_json $tmpdir/RELEASE
    format_json $tmpdir/HOSTNAME
    format_json $tmpdir/IP
    format_json $tmpdir/ROUTE end

    #end
    if [ $# -eq 0 ];then
       echo },
    else
       echo }
    fi
}

function get_esxi_cpu_info(){
    tmpdir=tmp/            
    echo \"cpu\":{
    #put the k:v to buffer.txt ,many more
    esxcli hardware cpu global get |grep -i "CPU" >$tmpdir/ESXI_CPU_LIST


    format_json $tmpdir/ESXI_CPU_LIST end
    
    #end                
    if [ $# -eq 0 ];then     
       echo },               
    else                     
       echo }                                                           
    fi 
}

function get_memory_info(){
    tmpdir=tmp/                                                                         
    echo \"memory\":{
    #put the k:v to buffer.txt ,many more        
    esxcli hardware memory get |grep -i "Physical Memory" > $tmpdir/ESXI_MEM_LIST
                                                                                        
                                                                                        
    format_json $tmpdir/ESXI_MEM_LIST end                                               
                                                                                
    #end                                                                        
    if [ $# -eq 0 ];then                                                        
       echo },                                                          
    else                                                                
       echo }                                                           
    fi  
}

function main(){
  echo {
    get_system_info
    get_esxi_cpu_info
    get_memory_info end
  echo }
}

main
