library(shiny)
library(ggplot2)
library(plyr)
library(httr)
library(drawProteins)
library(ggrepel)

#proteins_acc<-"P04637"#Uniprot accession numbers for TP53 human
proteins_acc<-read.table("UniProt.txt",header=T)
#template<-read.table("upload.data.txt",header=T,nrows=1)
template<-read.table("upload.data.txt",header=T)
template<-template[,1:4]

server<-function(input,output){
	getData<-reactive({
		inFile<-input$file1
		if(is.null(input$file1)) return(NULL)
		isolate({
  		#input$file1 will be NULL initially.After uploading a file,it will be a data frame with 'name','size','type',and 'datapath' columns.The 'datapath'column will contain the local filenames where the data can be found.
		var<-read.table(inFile$datapath,header=input$header,sep=input$sep)
		var<-unique(var[!duplicated(var),])#remove duplicates
		var[order(var$Hugo_Symbol,gsub("([A-Z]+)([0-9]+)","\\2",var$Protein_Change)),]#order
		var.freq<-count(var,c("Hugo_Symbol","Protein_Change","Mutation_Type"))
		var.aanum<-unlist(lapply(regmatches(var.freq$Protein_Change,gregexpr(pattern="*(\\d+)",var.freq$Protein_Change)),function(x) x[[1]]))
		var.plot.data<-cbind(var.freq,as.numeric(as.character(var.aanum)))#hard way to remove factor
		colnames(var.plot.data)[5]<-"var.aanum"
		return(var.plot.data)
		})
	})
	getTable<-reactive({
		var.plot.table<-isolate(getData())
		var.plot.table<-var.plot.table[var.plot.table$Hugo_Symbol==input$gene,]
		var.plot.table<-var.plot.table[order(var.plot.table$var.aanum),]
	})
	getPlot<-reactive({
		input$plot
		var.plot<-isolate(getData())
		var.plot<-var.plot[var.plot$Hugo_Symbol==input$gene,]
		var.plot<-var.plot[order(var.plot$var.aanum),]
		var.plot$Protein_Change<-as.character(var.plot$Protein_Change)
		p<-ggplot(var.plot,aes(var.aanum,freq,color=Mutation_Type,label=Protein_Change))+geom_segment(aes(x=var.aanum,y=0,xend=var.aanum,yend=freq),color=ifelse(var.plot$freq>=input$AAfreq,"orange","grey50"),size=ifelse(var.plot$freq>=input$AAfreq,1.3,0.7))+geom_point(size=7)+geom_text_repel(nudge_y=0.2,color=ifelse(var.plot$freq>=input$AAfreq,"orange","NA"),size=ifelse(var.plot$freq>=input$AAfreq,5,5),fontface="bold")
		proteins_acc<-proteins_acc[proteins_acc$Hugo_Symbol==input$gene,2]
		proteins_acc_url<-gsub(" ","%2C",proteins_acc)
		baseurl<-"https://www.ebi.ac.uk/proteins/api/features?offset=0&size=100&accession="
		url<-paste0(baseurl,proteins_acc_url)
		prots_feat<-GET(url,accept_json())
		prots_feat_red<-httr::content(prots_feat)
		features_total_plot<-NULL
		for(i in 1:length(prots_feat_red)){ 
   		features_temp<-drawProteins::extract_feat_acc(prots_feat_red[[i]])#the extract_feat_acc() function takes features into a data.frame
   		features_temp$order<-i # this order is needed for plotting later
   		features_total_plot<-rbind(features_total_plot,features_temp)
		}
		plot_start<-0#starts 0
		plot_end<-max(features_total_plot$end)
		if("CHAIN"%in%(unique(features_total_plot$type))) p<-p+geom_rect(data=features_total_plot[features_total_plot$type=="CHAIN",],mapping=aes(xmin=begin,xmax=end,ymin=-0.35,ymax=-0.1),colour="grey",fill="grey",inherit.aes=F)
		if("DNA_BIND"%in%(unique(features_total_plot$type))) {
		features_total_plot[features_total_plot$type=="DNA_BIND","description"]<-features_total_plot[features_total_plot$type=="DNA_BIND","type"]
		p<-p+geom_rect(data=features_total_plot[features_total_plot$type=="DNA_BIND",],mapping=aes(xmin=begin,xmax=end,ymin=-0.45,ymax=0,fill=description),inherit.aes=F)
		}
		if("DOMAIN"%in%(unique(features_total_plot$type))) p<-p+geom_rect(data=features_total_plot[features_total_plot$type=="DOMAIN",],mapping=aes(xmin=begin,xmax=end,ymin=-0.45,ymax=0,fill=description),inherit.aes=F)
		if("MOTIF"%in%(unique(features_total_plot$type))) p<-p+geom_rect(data=features_total_plot[features_total_plot$type=="MOTIF",],mapping=aes(xmin=begin,xmax=end,ymin=-0.45,ymax=0,fill=description),inherit.aes=F)
		p<-p+scale_x_continuous(breaks=round(seq(plot_start,plot_end,by=50)),name="Amino acid number")+theme(plot.title=element_text(face="bold",size=(15),hjust=0),axis.text.x=element_text(angle=90,hjust=1))+labs(y="Mutation frequency in our dataset",title=paste("Mutation frequency at ",input$gene," in the uploaded dataset",sep=""),subtitle="example\nprotein structure source:Uniprot")+scale_y_continuous(breaks=seq(0,max(var.plot$freq),1),name="frequency")
		p		
	})
	getDomain<-reactive({
		proteins_acc<-proteins_acc[proteins_acc$Hugo_Symbol==input$gene,2]
		proteins_acc_url<-gsub(" ","%2C",proteins_acc)
		baseurl<-"https://www.ebi.ac.uk/proteins/api/features?offset=0&size=100&accession="
		url<-paste0(baseurl,proteins_acc_url)
		prots_feat<-GET(url,accept_json())
		prots_feat_red<-httr::content(prots_feat)
		features_total_plot<-NULL
		for(i in 1:length(prots_feat_red)){ 
   		features_temp<-drawProteins::extract_feat_acc(prots_feat_red[[i]])#the extract_feat_acc() function takes features into a data.frame
   		features_temp$order<-i # this order is needed for plotting later
   		features_total_plot<-rbind(features_total_plot,features_temp)
		}
		features_total_plot<-subset(features_total_plot,type%in% c("CHAIN","DNA_BIND","DOMAIN","MOTIF"))
	})
	#I think it's not working due to renderTable import different data format
	output$freq<-renderTable({template})
	#output$plot<-renderPlot({isolate(getPlot())})
	output$downloadplot<-downloadHandler(
		filename=function(){ 
			paste(input$gene,"lollipop.",input$plotformat,sep="")
		},
		content=function(file){
			#write.csv(output$plot,file,row.names=F)
			ggsave(file,getPlot(),width=20,height=5,units="in")#change plot size
		})
	output$downloaddata<-downloadHandler(
		filename=function(){ 
			paste("new.",input$file1,".csv",sep="")
		},
		content=function(file){
			#write.csv(getData(),file,row.names=F)#not subsetted
			write.csv(getTable(),file,row.names=F)
		})
	output$downloaddomain<-downloadHandler(
		filename=function(){ 
			paste(input$gene,"domain.csv",sep="")
		},
		content=function(file){
			#write.csv(getData(),file,row.names=F)#not subsetted
			write.csv(getDomain(),file,row.names=F)
		})
}

#gene<-"TP53"
#runApp("E:/programs/R/research/shiny/lollipop.v2")