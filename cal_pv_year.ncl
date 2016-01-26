load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
    ;Script can be used to calculate the PV across pressure levels 
    ;customized for NCEP-NCAR outputs
    ;parallelized
    ;used in combine with cal_pv_year.sh 
    ;year    =   2015 
    air_finame      =   "../air/air."+year+".nc" 
    uwnd_finame     =   "../uwnd/uwnd."+year+".nc"
    vwnd_finame     =   "../vwnd/vwnd."+year+".nc"


    air_fi  =   addfile(air_finame,"r")
    uwnd_fi =   addfile(uwnd_finame,"r")
    vwnd_fi =   addfile(vwnd_finame,"r")
    
    air =   air_fi->air(:,:,::-1,:)
    ;air =   where(ismissing(air),air,air+273.15)
    uwnd    =   uwnd_fi->uwnd(:,:,::-1,:)
    vwnd    =   vwnd_fi->vwnd(:,:,::-1,:)


    lev = air&level  ; hPa
    lev = lev*100 ; convert units
    lev@units = "Pa"
    printMinMax(lev,0)
    printMinMax(air,0)

    lat = air&lat
    gridType  = 1          ; fixed grid
    opt = 0
    PV = pot_vort_isobaric(lev,uwnd,vwnd,air,lat, gridType, opt) 
    PV  =   where(ismissing(PV),PV@_FillValue,PV*1.0e6)

    out_fi_name =  "pv_"+year+".nc" 
    system("/bin/rm -f "+ out_fi_name)   ; remove any pre-existing file
    ncdf = addfile(out_fi_name ,"c")  ; open output netCDF file
    ncdf->pv   =  PV

end
