#!/usr/bin/python
import os
import unittest
import filecmp


WAN = 'enp2s0'
LAN = 'br0'

# TestIsUninstalled
#
# 1. Config Files and Directories
#       NOTExist( /etc/network/if.backup )
#       Exist( /etc/network/interfaces ), NOTEqual( /etc/network/interfaces, ~/Bay-Net-Client/routing/interfaces )
#       NOTExist( /etc/routing )
#       NOTExist( /etc/routing/routing.sh )
#       NOTExist( /etc/systemd/system/bay_routing.service )
#
# 2. Service
#       NOTMatch( GetServiceStatus( bay_routing.service ), active )
#
# 3. Iptables
#       NOTMatch( GetIptableRule( nat, POSTROUTING, WAN ), MASQUERADE*WAN )
#       NOTMatch( GetIptableRule( filter, FORWARD, WAN ), ACCEPTWANLANACCEPTLANWAN )

class test_Config_Files_and_Directories(unittest.TestCase):
    '''test whether config files and directories exist or equal'''
    def test_if_backup(self):
        '''test whether if.backup NOT exists'''
        self.assertFalse( Exist( '/etc/network/if.backup' ) )

    def test_interfaces(self):
        '''test whether /etc/network/interfaces exists and is NOT equal with /home/murka/Bay-Net-Client/routing/interfaces'''
        self.assertTrue( Exist( '/etc/network/interfaces' ) )
        self.assertFalse( Equal( '/etc/network/interfaces', '/home/murka/Bay-Net-Client/routing/interfaces' ) )
    
    def test_routing_dir(self):    
        '''test /etc/routing directory NOT exists'''
        self.assertFalse( Exist( '/etc/routing' ) )
    
    def test_routing_sh(self):
        '''test whether /etc/routing/routing.sh NOT exists'''
        self.assertFalse( Exist( '/etc/routing/routing.sh' ) )

    def test_bay_routing_service(self):
        '''test whether /etc/systemd/system/bay_routing.service NOT exists'''
        self.assertFalse( Exist( '/etc/systemd/system/bay_routing.service' ) )

class test_service( unittest.TestCase ):
    def test_service_is_active( self ):
        '''test whether bay_routing.service is NOT active'''    
        self.assertFalse( Match( GetServiceStatus( 'bay_routing.service' ), 'active' ) )    

class test_Iptables( unittest.TestCase ):
    '''test whether iptables rules exist'''
    def test_nat_POSTROUTING_MASQUERADE( self ):
        '''test whether MASQUERADE rules NOT exist'''
        self.assertFalse( Match( GetIptableRule( 'nat', 'POSTROUTING', WAN  ), 'MASQUERADE*%s' % ( WAN ) ) )

    def test_filter_FORWARD( self ):
        '''test whether LAN and WAN data can NOT exchange'''
        self.assertFalse( Match( GetIptableRule( 'filter', 'FORWARD', WAN ), 'ACCEPT%s%sACCEPT%s%s' % ( WAN, LAN, LAN, WAN ) ) )


def Exist( name ):
    '''test whether [name](file or directory) exist'''
    return os.path.exists( name )

def Equal( fileA,fileB ):
    '''test whether [fileA] and [fileB] are equal'''
    return filecmp.cmp( fileA, fileB )

def GetIP( interface ):
    '''get [interface] IP'''
    IP = os.popen("ifconfig %s | grep inet | head -n 1 | awk -F ':' '{print $2}' | awk '{print $1}'" % ( interface ) ).read().replace( '\n','' )
    return IP

def GetMask( interface ):
    '''get [interface] Netmask '''
    Mask = os.popen("ifconfig %s | grep inet |head -n 1 | awk '{print $4}' | awk -F ':' '{print $2}'" % ( interface ) ).read().replace( '\n','' )
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

