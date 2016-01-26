load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
    ;Script can be used to calculate the PV average across 150-500hPa
    ;customized for NCEP-NCAR 6h outputs
    ;parallelized
    ;used in combine with cal_pv_150_500hPa_ncep.sh 
    ;year    =   1948
    out_fi_name_r =  "./pv_out/pv_r."+year+".nc"  
    out_fi_name =  "./pv_out/pv."+year+".nc"  
    data_dir    =  "/home/hwy/WORK3/NCEP-NCAR/" 
    air_finame  =   data_dir+"air_6h/"+"air."+year+".nc"
    uwnd_finame =   data_dir+"uwnd_6h/"+"uwnd."+year+".nc"
    vwnd_finame =   data_dir+"vwnd_6h/"+"vwnd."+year+".nc"
    pres_sfc_finame =   data_dir+"pres.sfc_6h/"+"pres.sfc."+year+".nc"

    air_fi   =   addfile(air_finame,"r")
    uwnd_fi  =   addfile(uwnd_finame,"r")
    vwnd_fi  =   addfile(vwnd_finame,"r")
    pres_sfc_fi  =   addfile(pres_sfc_finame,"r")
    
    time    =   air_fi->time
    num_time    =   dimsizes(time)
    apv_out =   pres_sfc_fi->pres(:,::-1,:)
    ps      =   pres_sfc_fi->pres(:,::-1,:)

do k = 0, num_time-1
    air =   air_fi->air(k,{600:100},::-1,:)
    uwnd    =   uwnd_fi->uwnd(k,{600:100},::-1,:)
    vwnd    =   vwnd_fi->vwnd(k,{600:100},::-1,:)
    pres_sfc    =   pres_sfc_fi->pres(k,::-1,:)

    lev =   air&level
    lev =   lev*100
    lat =   air&lat
    gridType  = 1          ; fixed grid
    opt = 0
    PV  =   pot_vort_isobaric(lev,uwnd,vwnd,air,lat, gridType, opt) 
    pv  =   PV
    pv  =   where(ismissing(PV),PV,PV*1.e6)
    pv_avg_150_500  =   wgt_vert_avg_beta(lev, pv, pres_sfc, 1, (/1,15000,50000/))
    apv_out(k,:,:)  =   (/pv_avg_150_500/)
    print("k:"+k)
    printMinMax(pv_avg_150_500,0)
end do
    copy_VarMeta(ps,apv_out)
    printVarSummary(apv_out)
    delete_VarAtts(apv_out,"valid_range")
    delete_VarAtts(apv_out,"actual_range")
    system("/bin/rm -f "+ out_fi_name_r)
    system("/bin/rm -f "+ out_fi_name)
    ncdf = addfile(out_fi_name_r ,"c")
    ncdf->pv    =   apv_out
    system("ncks --mk_rec_dmn time "+ out_fi_name_r +" "+out_fi_name)
    system("/bin/rm -f "+ out_fi_name_r)
    ;printMinMax(air,0)
    ;printMinMax(uwnd,0)
    ;printMinMax(vwnd,0)
    ;printMinMax(pres_sfc,0)
    ;printVarSummary(air)
    ;printVarSummary(uwnd)
    ;printVarSummary(vwnd)
    ;printVarSummary(pres_sfc)
    ;printMinMax(lev,0)
    ;print(lev)
    ;printMinMax(pv,0)

    







end
