load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin
    ;Script can be used to calculate the PV average across 150-500hPa
    ;customized for CAM 6h outputs in *h2* files
    ;CESM version 1.2.1
    ;still not parallelization
    case    =   "ppdo_20160111"
    dir     =   "/home/hwy/WORK2/cesm1_2_1/archive/ppdo_20160111/atm/hist/" 
    out_dir =   "./apv_"+case+"/"

    years   =    34 
    yeare   =    60 
    mons    =   (/31,28,31,30,31,30,31,31,30,31,30,31/)
    print(sum(mons))

do i = years, yeare
do j = 1, 12
do kk = 1, mons(j-1)
        year_char   =   sprinti("%4.4i", i)
        mon_char    =   sprinti("%2.2i", j)
        day_char    =   sprinti("%2.2i", kk)
        finame      =   case+".cam.h2."+year_char+"-"+mon_char+"-"+day_char+"-00000.nc"
        outfiname   =   "temp.nc" 
        outfiname_r =   case+"_"+year_char+"-"+mon_char+"-"+day_char+".nc"
    print("fi_name: "+finame)

    fi      =   addfile(dir+finame,"r")
    ;printVarSummary(PS)
    printVarSummary(fi->PS)
    PS      =   fi->PS
    T       =   fi->T
    U       =   fi->U
    V       =   fi->V
    Z3      =   fi->Z3
    hyam    =   fi->hyam
    hybm    =   fi->hybm

    ;PS      =   where(ismissing(PS),PS@_FillValue,PS*0.01)
    pnew    =   (/500.0,400.0,300.0,200.0,150.0/)
    
    ;printMinMax(Z3,0)
    ;printMinMax(PS,0)
    ;printMinMax(hyam,0)
    ;printMinMax(hybm,0)

    
    vert_inter  =   2
    z3      =   vinth2p(Z3,hyam,hybm,pnew,PS,vert_inter,1000.0,1,False)
    u       =   vinth2p(U, hyam,hybm,pnew,PS,vert_inter,1000.0,1,False)
    v       =   vinth2p(V, hyam,hybm,pnew,PS,vert_inter,1000.0,1,False)
    t       =   vinth2p(T, hyam,hybm,pnew,PS,vert_inter,1000.0,1,False)
    lev     =   t&lev_p
    lev     =   lev*100.0
    lat     =   t&lat
    PV0     =   pot_vort_isobaric(lev,u,v,t,lat, 1, 0)
    PV      =   PV0
    PV      =   where(ismissing(PV0),PV0,1.0e6*PV0)
    APV     =   wgt_vert_avg_beta(lev, PV, PS, 1, (/1,15000,50000/))
    copy_VarMeta(PS,APV)
    printMinMax(APV,0)
    ;printMinMax(z3,0)
    ;printMinMax(u,0)
    ;printMinMax(v,0)
        ;printMinMax(t,0)
        ;printMinMax(lev,0)
        out_fi_name =   out_dir+outfiname 
        out_fi_name_r =   out_dir+outfiname_r 
        system("/bin/rm -f "+ out_fi_name)   ; remove any pre-existing file
        system("/bin/rm -f "+ out_fi_name_r)   ; remove any pre-existing file
        ncdf = addfile(out_fi_name ,"c")  ; open output netCDF file
        fAtt               = True            ; assign file attributes
        fAtt@title         = "Vertically averaged PV (150-500 hPa) for "+case
        fAtt@creation_date = systemfunc ("date")
        fAtt@author        = "Wen-Yu Huang (huangwenyu@mail.tsinghua.edu.cn)"
        fileattdef( ncdf, fAtt )            ; copy file attributes
        ncdf->pv   =   APV

        system("ncks --mk_rec_dmn time "+ out_fi_name +" "+out_fi_name_r)


        printVarSummary(PS)




end do
end do
end do


end
