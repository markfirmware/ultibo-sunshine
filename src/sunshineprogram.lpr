program SunshineProgram;
{$mode delphi}{$h+}

uses
 BCM2837,BCM2710,PlatformRPi3,
 GlobalConfig,GlobalConst,GlobalTypes,
 Classes,Console,FATFS,FileSystem,Logging,Platform,SysUtils,Threads,Ultibo,Vc4;//,Vc4Cec;

const
 MillisecondsPerSecond=1000;
 SecondsPerMinute=60;
 MillisecondsPerMinute=MillisecondsPerSecond * SecondsPerMinute;
 Milliseconds=1;
 Seconds=1;
 Minutes=1;

procedure StartLogging;
begin
  LOGGING_INCLUDE_TICKCOUNT:=True;
  LOGGING_INCLUDE_COUNTER:=False;
//LoggingDeviceSetTarget(LoggingDeviceFindByType(LOGGING_TYPE_FILE),'c:\ultibo-imaging-device.log');
//LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_FILE));
  CONSOLE_REGISTER_LOGGING:=True;
  LoggingConsoleDeviceAdd(ConsoleDeviceGetDefault);
  LoggingDeviceSetDefault(LoggingDeviceFindByType(LOGGING_TYPE_CONSOLE));
end;

var
 HostExists:Boolean=False;

procedure RestoreHostKernel;
begin
  while not DirectoryExists('c:\') do
   Sleep(Round(0.1 * Seconds * MillisecondsPerSecond));
  if FileExists('host-config.txt') then
   begin
    DeleteFile('config.txt');
    CopyFile('host-config.txt','config.txt',True);
    HostExists:=True;
   end;
end;

procedure Log(Message:String);
begin
 WriteLn(Message);
// LoggingOutput(Message);
end;

var
 RestartThreadHandle:TThreadHandle;

function RestartThread(Parameter:Pointer):PtrInt;
begin
 try
  try
   RestartThread:=0;
   Sleep(2 * Minutes * MillisecondsPerMinute);
   Log('');
   Log('program time limit exceeded');
   Log('program failure');
   Log('program stop');
   Log('');
  except on E:Exception do
   ;
  end;
 finally
  SystemRestart(1 * Seconds * MillisecondsPerSecond);
 end;
end;

procedure Check(Message:String;X:Boolean);
begin
 if not X then
  raise Exception.Create(Message);
end;

procedure Main;
begin
 RestoreHostKernel;
 BeginThread(@RestartThread,nil,RestartThreadHandle,THREAD_STACK_DEFAULT_SIZE);
 ConsoleWindowCreate(ConsoleDeviceGetDefault,CONSOLE_POSITION_FULL,True);
 StartLogging;
 Log('');
 Log('program start');
 Log('');
 Sleep(10 * Seconds * MillisecondsPerSecond);
end;

procedure UltiboKernelStamp(S:String);
begin
end;

begin
 UltiboKernelStamp('UltiboKernelStamp program ImagingIestProgram');
 try
  Main;
 except on E:Exception do
  begin
   Log(Format('ImagingTestProgram Exception.Message %s',[E.Message]));
    Sleep(5 * Seconds * MillisecondsPerSecond);
  end;
 end;
 Log('');
 Log('program stop');
 Log('');
 Sleep(10 * Seconds * MillisecondsPerSecond);
 if HostExists then
  SystemRestart(1 * Seconds * MillisecondsPerSecond);
end.
