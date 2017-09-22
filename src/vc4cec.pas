unit VC4CEC;

{$mode delphi}
{$H+}
{$inline on}

interface

uses
  Classes, SysUtils, VC4;

type
  TCECServiceCallback = procedure (Data : pointer; Reason, Param1, Param2, Param3, Param4 : LongWord); cdecl;

  TCEC_AllDevices = (
    CEC_AllDevices_eTV = 0,               // TV only
    CEC_AllDevices_eRec1,                 // Address for 1st Recording Device
    CEC_AllDevices_eRec2,                 // Address for 2nd Recording Device
    CEC_AllDevices_eSTB1,                 // Address for 1st SetTop Box Device
    CEC_AllDevices_eDVD1,                 // Address for 1st DVD Device
    CEC_AllDevices_eAudioSystem,          // Address for Audio Device
    CEC_AllDevices_eSTB2,                 // Address for 2nd SetTop Box Device
    CEC_AllDevices_eSTB3,                 // Address for 3rd SetTop Box Device
    CEC_AllDevices_eDVD2,                 // Address for 2nd DVD Device
    CEC_AllDevices_eRec3,                 // Address for 3rd Recording Device
    CEC_AllDevices_eSTB4,                 // Address for 4th Tuner Device
    CEC_AllDevices_eDVD3,                 // 11 Address for 3rd DVD Device
    CEC_AllDevices_eRsvd3,                // Reserved and cannot be used
    CEC_AllDevices_eRsvd4,                // Reserved and cannot be used
    CEC_AllDevices_eFreeUse,              // Free Address, use for any device
    CEC_AllDevices_eUnRegistered = 15);   // UnRegistered Devices

  PCEC_ALLDevices = ^TCEC_AllDevices;
  TVC_CEC_MESSAGE = packed record
    len : Longword;
    initiator : TCEC_AllDevices;
    follower : TCEC_AllDevices;
    payload : array [0..15] of byte;
  end;
  PVC_CEC_MESSAGE = ^TVC_CEC_MESSAGE;

  TCEC_DEVICE_TYPE = byte;
  TCEC_DISPLAY_CONTROL = byte;
 (*
     Meaning of device_attr is as follows (one per active logical device)
     bit 3-0 logical address (see CEC_AllDevices_T above)
     bit 7-4 device type (see CEC_DEVICE_TYPE_T above)
     bit 11-8 index to upstream device
     bit 15-12 number of downstream device
     bit 31-16 index of first 4 downstream devices
     To keep life simple we only show the first 4 connected downstream devices
 *)
  TTopology = packed record
    active_mask : word;
    num_devices : word;
    device_attr : array [0..15] of LongWord;
  end;
  PTopology = ^TTopology;

// API calls
procedure vc_vchi_cec_init (instance : VCHI_INSTANCE_T; connections : PPVCHI_CONNECTION_T; num_connections : Longword); cdecl; external libvchostif name 'vc_vchi_cec_init';
procedure vc_vchi_cec_stop; cdecl; external libvchostif name 'vc_vchi_cec_stop';
procedure vc_cec_register_callback (callback : TCECServiceCallback; Data : pointer); cdecl; external libvchostif name 'vc_cec_register_callback';
function vc_cec_register_command (opcode : byte) : integer; cdecl; external libvchostif name 'vc_cec_register_command';
function vc_cec_register_all : integer; cdecl; external libvchostif name 'vc_cec_register_all';
function vc_cec_deregister_command (opcode : byte) : integer; cdecl; external libvchostif name 'vc_cec_deregister_command';
function vc_cec_deregister_all : integer; cdecl; external libvchostif name 'vc_cec_deregister_all';
function vc_cec_send_message (const follower : LongWord; var payload : byte; len : Longword; is_replay : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_message';
function vc_cec_get_logical_address (var logical_address : TCEC_AllDevices) : integer; cdecl; external libvchostif name 'vc_cec_get_logical_address';
function vc_cec_alloc_logical_address : integer; cdecl; external libvchostif name 'vc_cec_alloc_logical_address';
function vc_cec_release_logical_address : integer; cdecl; external libvchostif name 'vc_cec_release_logical_address';
function vc_cec_get_topology (var topology : TTopology) : integer; cdecl; external libvchostif name 'vc_cec_get_topology';
function vc_cec_set_vendor_id (id : LongWord) : integer; cdecl; external libvchostif name 'vc_cec_set_vendor_id';
function vc_cec_set_osd_name (const name : PChar) : integer; cdecl; external libvchostif name 'vc_cec_set_osd_name';
function vc_cec_get_physical_address (var physical_address: Word) : integer; cdecl; external libvchostif name 'vc_cec_get_physical_address';
function vc_cec_get_vendor_id (const logical_address : TCEC_AllDevices; var vendor_id : Longword) : integer; cdecl; external libvchostif name 'vc_cec_get_vendor_id';
function vc_cec_device_type (const logical_address : TCEC_AllDevices) : byte; cdecl; external libvchostif name 'vc_cec_device_type';
function vc_cec_send_message2 (var message : TVC_CEC_MESSAGE) : integer; cdecl; external libvchostif name 'vc_cec_send_message2';
function vc_cec_param2message (const reason, param1, param2, param3, param4 : Longword;
                               var message : TVC_CEC_MESSAGE) : integer; cdecl; external libvchostif name 'vc_cec_param2message';
function vc_cec_poll_address (const logical_address : TCEC_AllDevices) : integer; cdecl; external libvchostif name 'vc_cec_poll_address';
function vc_cec_set_logical_address (const logical_address : TCEC_AllDevices;
                                     const device_type : TCEC_DEVICE_TYPE;
                                     const vendor_id : LongWord) : integer; cdecl; external libvchostif name 'vc_cec_set_logical_address';
function vc_cec_add_device (const  logical_address : TCEC_AllDevices;
                            const physical_address : Word;
                            const device_type : TCEC_DEVICE_TYPE;
                            last_device : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_add_device';
function vc_cec_set_passive (enabled : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_set_passive';
function vc_cec_send_FeatureAbort (follower : Longword;
                                   opcode : byte;
                                   reason : byte) : integer; cdecl; external libvchostif name 'vc_cec_send_FeatureAbort';
function vc_cec_send_ActiveSource (physical_address : Word; is_reply : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_ActiveSource';
function vc_cec_send_ImageViewOn (follower : Longword; is_reply : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_ImageViewOn';
function vc_cec_send_SetOSDString (follower : Longword;
                                   disp_ctrl : TCEC_DISPLAY_CONTROL;
                                   const string_ : PChar;
                                   is_reply : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_SetOSDString';
function vc_cec_send_Standby (follower : Longword; is_reply : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_Standby';
function vc_cec_send_MenuStatus (follower : Longword;
                                 menu_state : byte;
                                 is_reply : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_MenuStatus';
function vc_cec_send_ReportPhysicalAddress (physical_address : word;
                                            device_type : TCEC_DEVICE_TYPE;
                                            is_reply : WordBool) : integer; cdecl; external libvchostif name 'vc_cec_send_ReportPhysicalAddress';
var
  t1 : TCEC_AllDevices;
  pl : byte;
  r, p1, p2, p3 ,p4 : LongWord;
  m : TVC_CEC_MESSAGE;
  t : TTopology;
  a : word;
  i : VCHI_INSTANCE_T;

implementation

initialization

(* only added to see if linker is happy
  vc_vchi_cec_init (i, nil, 0);
  vc_cec_register_all;
  vc_vchi_cec_stop;
  vc_cec_register_callback (nil, nil);
  vc_cec_register_command (0);
  vc_cec_register_all;
  vc_cec_deregister_command (0);
  vc_cec_deregister_all;
  vc_cec_send_message (0, pl, 0, false);
  vc_cec_get_logical_address (t1);
  vc_cec_alloc_logical_address;
  vc_cec_release_logical_address;
  vc_cec_get_topology (t);
  vc_cec_set_vendor_id (0);
  vc_cec_set_osd_name ('hi');
  vc_cec_get_physical_address (a);
  vc_cec_get_vendor_id (t1, p1);
  vc_cec_device_type (t1);
  vc_cec_send_message2 (m);
  vc_cec_param2message (r, p1, p2, p3, p4, m);
  vc_cec_poll_address (t1);
  vc_cec_set_logical_address (t1, 0, 0);
  vc_cec_add_device (t1, 0, 0, false);
  vc_cec_set_passive (false);
  vc_cec_send_FeatureAbort (0, 0, 0);
  vc_cec_send_ActiveSource (0, false);
  vc_cec_send_ImageViewOn (0, false);
  vc_cec_send_SetOSDString (0, 0, '', false);
  vc_cec_send_Standby (0, false);
  vc_cec_send_MenuStatus (0, 0, false);
  vc_cec_send_ReportPhysicalAddress (0, 0, false);  *)

end.                                    
