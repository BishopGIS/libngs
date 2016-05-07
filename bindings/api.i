/* File : api.i */
%module api

%inline %{
extern int GetVersion();
extern const char* GetVersionString();
%}
