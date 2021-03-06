###################################################################################################
# Setup
# 
# Load the rwrfhydro package. 
## ------------------------------------------------------------------------
library("rwrfhydro")
load("/glade/p/ral/RHAP/adugger/Upper_RioGrande/ANALYSIS/urg_masks_NEW.Rdata")
load("/glade/p/ral/RHAP/adugger/Upper_RioGrande/OBS/SNOTEL/snotel_URG.Rdata")
load("/glade/p/ral/RHAP/adugger/Upper_RioGrande/OBS/MET/met_URG.Rdata")

# Where the processed data lives
rimgPath <- 'urg_wy2015_SNOCLIM_PROCESSED.Rdata'

# Where to write files
outPath <- 'plots'

# Range dates to restrict plots
stdate <- NULL
enddate <- as.POSIXct("2015-07-14 00:00", format="%Y-%m-%d %H:%M", tz="UTC")


###################################################################################################
# Run

load(rimgPath)
dir.create(outPath, showWarnings = FALSE)

source("PlotSWE.R")


## ------------------------------------------------------------------------
### PLOTS

sites <- unique(sno.URG.sites$site_id)
sites <- c(sites, unique(met.URG.sites$site_id))

# Accumulated precip and SWE plots: NLDAS & Snow Mods & Mike Recs
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/cumprec_swe_nldas_snowmods_", sites[n], ".png"), width=800, height=500)
  PlotSwe(sites[n], modDfs=list(modLdasout_wy2015_NLDAS2dwnsc_fullrtng_SNO, 
				modLdasout_wy2015_NLDAS2dwnsc_snowmod_fullrtng_SNO,
				modLdasout_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng_SNO),
		obs=sno.URG.data, obsmeta=sno.URG.sites, 
          	labMods=c("Model1: NLDAS Precip, Base", 
			"Model2: NLDAS Precip, NoahMP Snow Mods",
			"Model3: NLDAS Precip, NoahMP Snow Mods, Mike Recs"),
		lnCols=c('chocolate', 'dodgerblue', 'chartreuse3'),
		lnWds=c(2,2,2,2))
  dev.off()
}

# Accumulated precip and SWE plots: NSSL & Snow Mods
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/cumprec_swe_nssl_snowmods_", sites[n], ".png"), width=800, height=500)
  PlotSwe(sites[n], modDfs=list(modLdasout_wy2015_NLDAS2dwnsc_NSSL_fullrtng_SNO, 
				modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_fullrtng_SNO,
 				modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_fullrtng_SNO,
                                modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_nlcd11_fullrtng_SNO),
                obs=sno.URG.data, obsmeta=sno.URG.sites,
                labMods=c("Model1: NSSL Precip, Base",
                        "Model2: NSSL Precip, NoahMP Snow Mods",
                        "Model3: NSSL Precip, NoahMP Snow Mods, Mike Recs",
                        "Model4: NSSL Precip, NoahMP Snow Mods, Mike Recs, NLCD 2011"),
                lnCols=c('chocolate', 'dodgerblue', 'chartreuse3', 'purple'),
		lnWds=c(2,2,2,2,2))
  dev.off()
}

# Boxplot
stats_sno_all$runsort <- factor(stats_sno_all$run, as.character(stats_sno_all$run))
gg <- ggplot(data=stats_sno_all, aes(x=runsort, y=t_bias, color=runsort)) +
        geom_boxplot() +
	theme(axis.ticks = element_blank(), axis.text.x = element_blank()) +
	ylab("SWE Bias (%)") + xlab("Model Run") +
        scale_color_manual(values=c("darkblue","brown4","dodgerblue","coral2","cadetblue2","sandybrown","olivedrab","pink"), name="Model Run") +
        ggtitle("SWE Bias (Oct 1, 2014 through ~Jun 30, 2015)") +
        geom_hline(yintercept=0)
ggsave(filename=paste0(outPath, "/stats_sno_bias.png"), plot=gg,
       units="in", width=12, height=6, dpi=100)

# PRESENTATION

# Accumulated precip and SWE plots
sites <- unique(sno.URG.sites$site_id)
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/cumprec_swe_pres_", sites[n], ".png"), width=2100, height=1350, res=225)
  PlotSwe(sites[n], modDfs=list(modLdasout_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng_SNO,
				modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_fullrtng_SNO),
                obs=sno.URG.data, obsmeta=sno.URG.sites,
		labMods=c("Model1: NLDAS-2", "Model2: NLDAS-2 + NSSL Precipitation"),
                lnCols=c('dodgerblue', 'darkorange1'),
                lnWds=c(3,3))
  dev.off()
}

sites <- unique(met.URG.sites$site_id)
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/cumprec_swe_pres_", sites[n], ".png"), width=2100, height=1350, res=225)
  PlotSwe(sites[n], modDfs=list(modLdasout_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng_SNO,
                                modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_fullrtng_SNO),
                obs=met.URG.data.dy, obsmeta=met.URG.sites,
                labMods=c("Model1: NLDAS-2", "Model2: NSSL Precipitation"),
                lnCols=c('dodgerblue', 'darkorange1'),
                lnWds=c(3,3),
		precCol.obs="PrecAcc_max", precCol.mod="ACCPRCP", 
		sweCol.obs="SnoDep_mean", sweCol.mod="SNOWH", fact=1000, snowh=TRUE,
		labTitle="Accumulated Precipitation and Snow Depth",
		#stdate_prec=as.POSIXct("2014-11-21", format="%Y-%m-%d", tz="UTC"))
		stdate_prec=min(subset(met.URG.data.dy$POSIXct, met.URG.data.dy$site_id==sites[n])))
  dev.off()
}

sites <- unique(sno.URG.sites$site_id)
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/cumprec_swe_resistmods_pres_", sites[n], ".png"), width=2100, height=1350, res=225)
  PlotSwe(sites[n], modDfs=list(modLdasout_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng_SNO,
                                modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_fullrtng_SNO,
                                modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng_SNO),
                obs=sno.URG.data, obsmeta=sno.URG.sites,
                labMods=c("Model1: NLDAS-2", "Model2: NSSL Precipitation", "Model3: NSSL w/Resistance Mods"),
                lnCols=c('dodgerblue', 'darkorange1', 'olivedrab'),
                lnWds=c(3,3,3),
                precCol.obs="CumPrec_mm", precCol.mod="ACCPRCP",
                sweCol.obs="SWE_mm", sweCol.mod="SNEQV", fact=1, snowh=FALSE,
                labTitle="Accumulated Precipitation and SWE",
                #stdate_prec=as.POSIXct("2014-11-21", format="%Y-%m-%d", tz="UTC"))
                stdate_prec=min(subset(sno.URG.data$POSIXct, sno.URG.data$site_id==sites[n])))
  dev.off()
}

sites <- unique(met.URG.sites$site_id)
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/cumprec_swe_resistmods_pres_", sites[n], ".png"), width=2100, height=1350, res=225)
  PlotSwe(sites[n], modDfs=list(modLdasout_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng_SNO,
                                modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_fullrtng_SNO,
				modLdasout_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng_SNO),
                obs=met.URG.data.dy, obsmeta=met.URG.sites,
                labMods=c("Model1: NLDAS-2", "Model2: NSSL Precipitation", "Model3: NSSL w/Resistance Mods"),
                lnCols=c('dodgerblue', 'darkorange1', 'olivedrab'),
                lnWds=c(3,3,3),
                precCol.obs="PrecAcc_max", precCol.mod="ACCPRCP",
                sweCol.obs="SnoDep_mean", sweCol.mod="SNOWH", fact=1000, snowh=TRUE,
                labTitle="Accumulated Precipitation and Snow Depth",
                #stdate_prec=as.POSIXct("2014-11-21", format="%Y-%m-%d", tz="UTC"))
                stdate_prec=min(subset(met.URG.data.dy$POSIXct, met.URG.data.dy$site_id==sites[n])))
  dev.off()
}

# MET
# Temperature
sites <- unique(met.URG.sites$site_id)
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/met_temp_", sites[n], ".png"), width=1350, height=2100, res=225)
  PlotMet(obs=met.URG.data.dy, 
			mod=modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO.metd, 
			site=sites[n], 
			obsVars=c("Tmean_K", "Tmax_K", "Tmin_K"), 
			modVars=c("T2D_mean", "T2D_max", "T2D_min"), 
			lnLabs=c("Mean Temp (C)", "Max Temp (C)", "Min Temp (C)"), 
			title=paste0(met.URG.sites$site_name[met.URG.sites$site_id==n], ":\nDaily Temperature"),
			xLab="WY2015", 
			adj=(-273.15))
  dev.off()
}

# Radiation
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/met_swrad_", sites[n], ".png"), width=1350, height=2100, res=225)
  PlotMet(obs=met.URG.data.dy,
                        mod=modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO.metd,
                        site=sites[n],
                        obsVars=c("SWRad_mean", "SWRad_max", "SWRad_min"),
                        modVars=c("SWDOWN_mean", "SWDOWN_max", "SWDOWN_min"),
                        lnLabs=c("Mean Rad (W/m2)", "Max Rad (W/m2)", "Min Rad (W/m2)"),
                        title=paste0(met.URG.sites$site_name[met.URG.sites$site_id==n], ":\nDaily Shortwave Radiation"),
			xLab="WY2015")
  dev.off()
}

# Wind
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/met_wind_", sites[n], ".png"), width=1350, height=2100, res=225)
  PlotMet(obs=met.URG.data.dy,
                        mod=modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO.metd,
                        site=sites[n],
                        obsVars=c("Wind_mean", "Wind_max", "Wind_min"),
                        modVars=c("Wind_mean", "Wind_max", "Wind_min"),
                        lnLabs=c("Mean Speed (m/s)", "Max Speed (m/s)", "Min Speed (m/s)"),
                        title=paste0(met.URG.sites$site_name[met.URG.sites$site_id==n], ":\nDaily Wind Speed"),
			xLab="WY2015")
  dev.off()
}

# Humidity
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/met_relhum_", sites[n], ".png"), width=1350, height=2100, res=225)
  PlotMet(obs=met.URG.data.dy,
                        mod=modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO.metd,
                        site=sites[n],
                        obsVars=c("RH_mean", "RH_max", "RH_min"),
                        modVars=c("RelHum_mean", "RelHum_max", "RelHum_min"),
                        lnLabs=c("Mean RH (0-1)", "Max RH (0-1)", "Min RH (0-1)"),
                        title=paste0(met.URG.sites$site_name[met.URG.sites$site_id==n], ":\nRelative Humidity"),
			xLab="WY2015")
  dev.off()
}

# Pressure
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/met_press_", sites[n], ".png"), width=1350, height=2100, res=225)
  PlotMet(obs=met.URG.data.dy,
                        mod=modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO.metd,
                        site=sites[n],
                        obsVars=c("SurfPressmean_Pa", "SurfPressmax_Pa", "SurfPressmin_Pa"),
                        modVars=c("PSFC_mean", "PSFC_max", "PSFC_min"),
                        lnLabs=c("Mean Press (kPa)", "Max Press (kPa)", "Min Press (kPa)"),
                        title=paste0(met.URG.sites$site_name[met.URG.sites$site_id==n], ":\nSurface Pressure"),
			xLab="WY2015",			
			mult=0.001)
  dev.off()
}

# MSD by Station
# Temperature
png(paste0(outPath, "/met_msd_temp_ALL.png"), width=1900, height=1350, res=225)
ggplot() + geom_point(data=subset(stats_met_all, stats_met_all$var=="Temp"), aes(x=site_fact, y=dy_msd, color=as.factor(seas)), size=4) + 
	scale_color_manual(values=c("All"="Purple", "Sub"="Orange"), labels=c("Full Period", "Spring"), name="Time Period") + 
	labs(y="Mean Signed Deviation (deg C)", x=element_blank(), title="Error in Mean Daily Temperature (NLDAS minus Met Obs)") + 
	theme_bw() + 
	theme(plot.title = element_text(size=14, face="bold", vjust=2), axis.text.x=element_text(size=12, angle=50, vjust=0.5), 
		legend.justification=c(0,1), legend.position=c(0,1))
dev.off()

# Radiation
png(paste0(outPath, "/met_msd_rad_ALL.png"), width=1900, height=1350, res=225)
ggplot() + geom_point(data=subset(stats_met_all, stats_met_all$var=="SWRad"), aes(x=site_fact, y=dy_msd, color=as.factor(seas)), size=4) + 
        scale_color_manual(values=c("All"="Purple", "Sub"="Orange"), labels=c("Full Period", "Spring"), name="Time Period") + 
        labs(y="Mean Signed Deviation (W/m2)", x=element_blank(), title="Error in Downward Shortwave Radiation (NLDAS minus Met Obs)") + 
        theme_bw() + 
        theme(plot.title = element_text(size=14, face="bold", vjust=2), axis.text.x=element_text(size=12, angle=50, vjust=0.5), 
                legend.justification=c(0,1), legend.position=c(0,1))
dev.off()

# Sample day radiation
for (n in 1:length(sites)) {
  print(sites[n])
  png(paste0(outPath, "/met_apr1rad_", sites[n],".png"), width=1900, height=1350, res=225)
  with(subset(modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO, modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO$statArg==n & 
	modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO$POSIXct>=as.POSIXct("2015-04-01 07:00", format="%Y-%m-%d %H:%M", tz="UTC") & 
	modLdasin_wy2015_NLDAS2dwnsc_fullrtng_SNO$POSIXct<as.POSIXct("2015-04-02 07:00", format="%Y-%m-%d %H:%M", tz="UTC")), 
	plot(POSIXct, SWDOWN, typ='l', ylim=c(0, 1200), col='red', lwd=2, 
		main=paste0("SW Radiation, April 1, 2015: ", met.URG.sites$site_name[met.URG.sites$site_id==n]), 
		ylab="Radiation (W/m2)", xlab="UTC Time"))
  with(subset(met.URG.data, met.URG.data$site_id==n), lines(POSIXct, shortwave_radiation, col='black', lwd=2))
  legend("topleft", c("OBS","NLDAS"), col=c("black","red"), lty=c(1,1), lwd=c(2,2))
  dev.off()
}


# PRECIP BIAS
# Bias
lm.nldas <- lm(subset(stats_sno_all$dy_bias, stats_sno_all$var=="Precip" & 
			stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" &
			stats_sno_all$seas=="Sub" & 
                	stats_sno_all$in_nssl==1) ~ 
		subset(stats_sno_all$elev, stats_sno_all$var=="Precip" & 
			stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" &
                        stats_sno_all$seas=="Sub" &
                        stats_sno_all$in_nssl==1))
lm.nssl <- lm(subset(stats_sno_all$dy_bias, stats_sno_all$var=="Precip" & 
			stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" &
			stats_sno_all$seas=="Sub" &        
                        stats_sno_all$in_nssl==1) ~ 
		subset(stats_sno_all$elev, stats_sno_all$var=="Precip" & 
			stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" &
			stats_sno_all$seas=="Sub" &        
                        stats_sno_all$in_nssl==1))
png(paste0(outPath, "/precipbias_snotel.png"), width=2100, height=1350, res=225)
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & 
			stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" &
                        stats_sno_all$seas=="Sub" &        
                        stats_sno_all$in_nssl==1), 
	plot(elev, dy_bias, ylim=c(-100,100), col='blue', pch=15, 
	xlab="Elevation (ft)", ylab="% Bias"))
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & 
                        stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" &
                        stats_sno_all$seas=="Sub" &
                        stats_sno_all$in_nssl==1),
	points(elev, dy_bias, col='red', cex=1.5))
with(subset(stats_met_all, stats_met_all$var=="Precip" & 
			stats_met_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" &
                        stats_met_all$seas=="Sub"), 
	points(elev, dy_bias, col='green2', pch=15))
with(subset(stats_met_all, stats_met_all$var=="Precip" & 
                        stats_met_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" &
                        stats_met_all$seas=="Sub"),
	points(elev, dy_bias, col='green', cex=1.5))
with(subset(stats_sno_all, stats_sno_all$var=="Precip" &
                        (stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" | 
			stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng") &
                        stats_sno_all$seas=="Sub" &
                        stats_sno_all$in_nssl==1 & (stats_sno_all$site_name=="Lily Pond " | stats_sno_all$site_name=="Cumbres Trestle ")),
        points(elev, dy_bias, col='black', cex=3.0))
with(subset(stats_met_all, stats_met_all$var=="Precip" &
                        (stats_met_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" | 
			stats_met_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng") &
                        stats_met_all$seas=="Sub"),
        points(elev, dy_bias, col='black', cex=3.0))
abline(h=0)
abline(v=10000)
abline(lm.nldas, col='blue')
abline(lm.nssl, col='red')
legend("topright", c(paste0("NLDAS to SNOTEL: slope=",round(lm.nldas$coefficients[[2]],4),
	", p=",round(unname(pf(summary(lm.nldas)$fstatistic[1],summary(lm.nldas)$fstatistic[2],summary(lm.nldas)$fstatistic[3],lower.tail=F)),4),
	", R-sq=",round(summary(lm.nldas)$r.squared,2)),
	paste0("NSSL to SNOTEL: slope=",round(lm.nssl$coefficients[[2]],4),
	", p=",round(unname(pf(summary(lm.nssl)$fstatistic[1],summary(lm.nssl)$fstatistic[2],summary(lm.nssl)$fstatistic[3],lower.tail=F)),4),
	", R-sq=",round(summary(lm.nssl)$r.squared,2)), "NLDAS to MET", "NSSL to MET"), 
	pch=c(15,1,15,1), col=c("blue", "red", "green2", "green"), pt.cex=c(1,1.5,1,1.5), bg="white")
title("Precipitation bias at SNOTEL and MET sites (Dec 2014 - Apr 2015)")
dev.off()

# RMSE
png(paste0(outPath, "/preciprmse_snotel.png"), width=2100, height=1350, res=225)
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng"),
        plot(elev, dy_rmse, ylim=c(1,7), col='blue', pch=15,
        xlab="Elevation (ft)", ylab="RMSE (mm)"))
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng"), 
	points(elev, dy_rmse, col='red', cex=1.5))
abline(v=10000)
legend("topleft", c("NLDAS", "NSSL"),
        lty=c(1,1), col=c("blue","red"), lwd=c(1,1))
title("Precipitation RMSE at SNOTEL sites")
dev.off()

# MSD
png(paste0(outPath, "/precipmsd_snotel.png"), width=2100, height=1350, res=225)
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_fullrtng"),
        plot(elev, dy_msd, ylim=c(-2,1.5), col='blue', pch=15,
        xlab="Elevation (ft)", ylab="Mean Signed Deviation (mm)"))
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng"), 
        points(elev, dy_msd, col='red', cex=1.5))
abline(h=0)
abline(v=10000)
legend("topleft", c("NLDAS", "NSSL"),
        lty=c(1,1), col=c("blue","red"), lwd=c(1,1))
title("Precipitation Mean Deviation at SNOTEL sites")
dev.off()

# Correlation
png(paste0(outPath, "/precipcor_snotel.png"), width=2100, height=1350, res=225)
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & 
		stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" & 
		stats_sno_all$seas=="Sub" & 
		stats_sno_all$in_nssl==1),
        plot(elev, dy_cor, ylim=c(0,1.4), col='blue', pch=15,
        xlab="Elevation (ft)", ylab="Correlation"))
with(subset(stats_sno_all, stats_sno_all$var=="Precip" & 
		stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" & 
		stats_sno_all$seas=="Sub" & 
		stats_sno_all$in_nssl==1),
        points(elev, dy_cor, col='red', cex=1.5))
with(subset(stats_met_all, stats_met_all$var=="Precip" & 
		stats_met_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" & 
		stats_met_all$seas=="Sub"), 
        points(elev, dy_cor, col='green2', pch=15))
with(subset(stats_met_all, stats_met_all$var=="Precip" & 
		stats_met_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" & 
		stats_met_all$seas=="Sub"), 
        points(elev, dy_cor, col='green', cex=1.5))
with(subset(stats_sno_all, stats_sno_all$var=="Precip" &
                        (stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" |
                        stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng") &
                        stats_sno_all$seas=="Sub" &
                        stats_sno_all$in_nssl==1 & (stats_sno_all$site_name=="Lily Pond " | stats_sno_all$site_name=="Cumbres Trestle ")),
        points(elev, dy_cor, col='black', cex=3.0))
with(subset(stats_met_all, stats_met_all$var=="Precip" &
                        (stats_met_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" |
                        stats_met_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng") &
                        stats_met_all$seas=="Sub"),
        points(elev, dy_cor, col='black', cex=3.0))
abline(v=10000)
abline(h=mean(subset(stats_sno_all$dy_cor, stats_sno_all$var=="Precip" &
                stats_sno_all$run=="_wy2015_NLDAS2dwnsc_snowmod_mikerec_snowresist50_fullrtng" &
                stats_sno_all$seas=="Sub" & 
                stats_sno_all$in_nssl==1)), col='blue', lty=2)
abline(h=mean(subset(stats_sno_all$dy_cor, stats_sno_all$var=="Precip" &
                stats_sno_all$run=="_wy2015_NLDAS2dwnsc_NSSL_snowmod_mikerec_snowresist50_fullrtng" &
                stats_sno_all$seas=="Sub" &
                stats_sno_all$in_nssl==1)), col='red', lty=2)
legend("topright", c("NLDAS to SNOTEL","NSSL to SNOTEL", "NLDAS to MET", "NSSL to MET"), 
        pch=c(15,1,15,1), col=c("blue", "red", "green2", "green"), pt.cex=c(1,1.5,1,1.5), bg="white")
title("Precipitation correlation at SNOTEL and MET sites (Dec 2014 - Apr 2015")
dev.off()

### EXIT

quit("no")

