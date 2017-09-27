#!/usr/bin/python
import os
import unittest
import filecmp
#import sys

WAN = 'enp2s0'
LAN = 'br0'

# TestIsInstalled
#
# 1. Config Files and Directories
#       Exist( /etc/network/if.backup )
#       Exist( /etc/network/interfaces ), Equal( /etc/network/interfaces, ~/Bay-Net-Client/routing/interfaces )
#       Exist( /etc/routing )
#       Exist( /etc/routing/routing.sh ), Equal( /etc/routing/routing.sh, ~/Bay-Net-Client/routing/routing.sh )
#       Exist( /etc/systemd/system/bay_routing.service ), Equal( /etc/systemd/system/bay_routing.service, ~/Bay-Net-Client/routing/bay_routing.service)
#
# 2. Interfaces Informations
#       Match( GetIP( enp2s0 ), 192.168.*.* ), Match( GetMask( enp2s0 ), 255.255.255.0 )
#       Match( GetIP( br0 ), 192.168.0.1 ), Match( GetMask( br0 ), 255.255.254.0 )
#
# 3. Service
#       Match( GetServiceStatus( bay_routing.service ), active )
#
# 4. Iptables
#       Match( GetIptableRule( nat, POSTROUTING, WAN ), MASQUERADE*WAN )
#       Match( GetIptableRule( filter, FORWARD, WAN ), ACCEPTWANLANACCEPTLANWAN )

class test_Config_Files_and_Directories(unittest.TestCase):
    '''test whether config files and directories exist or equal'''
    def test_if_backup(self):
        '''test whether if.backup exists'''
        self.assertTrue( Exist( '/etc/network/if.backup' ) )

    def test_interfaces(self):
        '''test whether /etc/network/interfaces exists and is equal with /home/murka/Bay-Net-Client/routing/interfaces'''
        self.assertTrue( Exist( '/etc/network/interfaces' ) )
        self.assertTrue( Equal( '/etc/network/interfaces', '/home/murka/Bay-Net-Client/routing/interfaces' ) )
    
    def test_routing_dir(self):    
        '''test /etc/routing directory exists'''
        self.assertTrue( Exist( '/etc/routing' ) )
    
    def test_routing_sh(self):
        '''test whether /etc/routing/routing.sh exists and is equal with ~/Bay-Net-Client/routing/routing.sh'''
        self.assertTrue( Exist( '/etc/routing/routing.sh' ) )
        self.assertTrue( Equal( '/etc/routing/routing.sh', '/home/murka/Bay-Net-Client/routing/routing.sh' ) )

    def test_bay_routing_service(self):
        '''test whether /etc/systemd/system/bay_routing.service exists and is equal with ~/Bay-Net-Client/routing/bay_routing.service'''
        self.assertTrue( Exist( '/etc/systemd/system/bay_routing.service' ) )
        self.assertTrue( Equal( '/etc/systemd/system/bay_routing.service', '/home/murka/Bay-Net-Client/routing/bay_routing.service' ) )

class test_Interfaces_Information( unittest.TestCase ):
    '''test interfaces '''
    def test_WAN_IP( self ):
        '''test whether WAN IP is 192.168.xxx.xxx'''
#    self.assertTrue( Match( GetIP( WAN ), 192.168.[0-9] ) )

    def test_WAN_netmask( self ):
        '''test whether WAN netmask is 255.255.255.0'''
        self.assertTrue( Match( GetMask( WAN ), '255.255.255.0' ) )

    def test_LAN_IP( self ):
        '''test whether LAN IP is 192.168.0.1'''
        self.assertTrue( Match( GetIP( LAN ), '192.168.0.1' ) )

    def test_LAN_natmask( self ):
        '''test whether LAN netmask is 255.255.254.0'''
        self.assertTrue( Match( GetMask( LAN ), '255.255.254.0' ) )

class test_service( unittest.TestCase ):
    def test_service_is_active( self ):
        '''test whether bay_routing.service is active'''    
        self.assertTrue( Match( GetServiceStatus( 'bay_routing.service' ), 'active' ) )    

class test_Iptables( unittest.TestCase ):
    '''test whether iptables rules exist'''
    def test_nat_POSTROUTING_MASQUERADE( self ):
        '''test whether MASQUERADE rules exist'''
        self.assertTrue( Match( GetIptableRule( 'nat', 'POSTROUTING', WAN  ), 'MASQUERADE*%s' % ( WAN ) ) )

    def test_filter_FORWARD( self ):
        '''test whether LAN and WAN data can exchange'''
        self.assertTrue( Match( GetIptableRule( 'filter', 'FORWARD', WAN ), 'ACCEPT%s%sACCEPT%s%s' % ( WAN, LAN, LAN, WAN ) ) )


def Exist( name ):
    '''test whether [name](file or directory) exist'''
    return os.path.exists( name )

def Equal( fileA,fileB ):
    '''test whether [fileA] and [fileB] are equal'''
    return filecmp.cmp( fileA, fileB )

def GetIP( interface ):
    '''get [interface] IP'''
    IP = os.popen("ifconfig %s | grep inet | head -n -1 | awk -F ':' '{print $2}' | awk '{print $1}'" % ( interface ) ).read().replace( '\n','' )
    return IP

def GetMask( interface ):
    '''get [interface] Netmask '''
    Mask = os.popen("ifconfig %s | grep inet | head -n -1 | awk '{print $4}' | awk -F ':' '{print $2}'" % ( interface ) ).read().replace( '\n','' )
    return Mask

def GetServiceStatus( servicename ):
    '''get [servicename] status'''
    status = os.popen("systemctl status %s | grep Active | awk '{print $2}'" % ( servicename ) ).read().replace( '\n','' )
    return status

def GetIptableRule( table, chain, interface ):
    '''get iptable rule in [table] [chain] and grep [interface]'''
    rule = os.popen( "sudo iptables -t %s -L %s -nv|grep %s |awk '{print $3 $6 $7}'" % ( table, chain, interface ) ).read().replace( '\n','' )
    return rule

def Match( code, correct ):
    '''test whether the function output [code] and right status [correct] are match'''
    if code == correct:
        return True
    else:
        return False

if __name__ == '__main__':
    unittest.main()



#switch = {
#        'IsInstalled':TestIsInstalled,
#        'IsUninstalled':TestIsUninstalled
#        }
#try:
#    switch[ sys.argv[1] ]()
#except:
#    print 'Usage: ./%s %s' % (sys.argv[0], switch.keys())
