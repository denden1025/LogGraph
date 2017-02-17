##################################################################
#ログファイル集計＆グラフ化     LogGraph.pm                      #
#（MTプラグインMultiCounterX 連携可）                            #
#    2017/2/17 V1.0.0.1    Win対応                               #
#                    denden   webkoza.com                        #
##################################################################

package Sitelog::LogGraph;
use GD;
use GD::Graph::mixed;
use GD::Graph::pie;
# クラス変数定義
our (
$EX_LOCK, #ｆｌｏｃｋの排他ロックモード
$UNLOCK,  #ｆｌｏｃｋの解除
$Pa,$Ya,$Mo,$FilePath,$LOGFILE,
@DayNo,@DayNinzu,@Agent_iPhone,@Agent_iPod,@Agent_iPad,@Agent_AndroidStd,@Agent_AndroidOpera,
@Agent_AndroidFirefox,@Agent_WH,@Agent_BB,@Agent_Sym,@Agent_IE9,@Agent_IE10,@Agent_IE11,
@Agent_IE8,@Agent_IEOther,@Agent_GC,@Agent_Lunascape,@Agent_Safari,@Agent_Opera,@Agent_bot,
@Agent_NMFirefox,@Agent_Au,@Agent_Doco,@Agent_Softb,@Agent_other,
$DayNinzu_num,$Agent_iPhone_num,$Agent_iPod_num,$Agent_iPad_num,$Agent_AndroidStd_num,
$Agent_AndroidOpera_num,$Agent_AndroidFirefox_num,$Agent_WH_num,$Agent_BB_num,$Agent_Sym_num,
$Agent_IE9_num,$Agent_IE10_num,$Agent_IE11_num,$Agent_IE8_num,$Agent_IEOther_num,
$Agent_GC_num,$Agent_Lunascape_num,$Agent_Safari_num,$Agent_Opera_num,$Agent_bot_num,
$Agent_NMFirefox_num,$Agent_Au_num,$Agent_Doco_num,$Agent_Softb_num,$Agent_other_num,
$Q,$im,$TITLE,$Font,$FontPath
);
# オブジェクトメソッド

sub new {
 my ($class,$q) = @_;
 $Q = $q; # CGI::PSGI オブジェクトリファをクラス変数にコピー
 my @headers = $Q->psgi_header('text/html');
 my $self = {
	Status => $headers[0],
	CT => $headers[1],
#	Status_CT => ['Content-Type'=>'text/html'],
	BODY => '<html><body>Hello PSGI 1234567890</body></html>',#Dummy
	@_,
 };
 return bless $self,$class;
}
sub to_app {
 my $self = shift;
 my @headers = $Q->psgi_header('image/png');
 $self->status($headers[0]); #
 $self->ct($headers[1]); # Content-Typeをイメージに変更
 $self->body(makeimage());
 return [$self->{Status},$self->{CT},[$self->{BODY}]];
}
sub status {
  my $self = shift;
  if( @_ ){ $self->{Status} = shift }
  return $self->{Status};
}
sub ct {
  my $self = shift;
  if( @_ ){ $self->{CT} = shift }
  return $self->{CT};
}
sub body {
  my $self = shift;
  if( @_ ){
  	$self->{BODY} = shift;
  }
  return $self->{BODY};
}

#************** Main **************
sub auth_user{
my ($id,$ps)=@_;
if(($Q->param('id') eq $id) and ($Q->param('ps') eq $ps)){
	return 'ok';
};
return 'ng';
}
#=================================
sub makeimage { # body 生成

my $rw; #データセット関数の戻り値 0以外＝エラーなのでエラーイメージ出力へ
my @ww =('');
#--------グローバル変数セット---------
$UAID = 13;
$EX_LOCK=2; #ｆｌｏｃｋの排他ロックモード
$UNLOCK=8;  #ｆｌｏｃｋの解除
$Pa = $Q->param('page');
$Ya = $Q->param('year');
$Mo = $Q->param('month');
$TITLE = $Q->param('kizititle');
$TITLE =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg; #un escape
$FilePath = $Q->param('logdir'); # 20170204
if($^O =~ /MSWin/){
	$LOGFILE = $FilePath . "\\" . $Pa . "\\img" . $Ya . "_" . $Mo . ".txt";
	@ww = split(m|\\|,$Q->param("fontfile"));
	$Font = [splice(@ww,$#ww)]->[0];
	$FontPath = join("\\",@ww) . "\\";
}else{
	$LOGFILE = $FilePath . '/' . $Pa . '/img' . $Ya . '_' . $Mo . '.txt';
	@ww = split('/',$Q->param('fontfile'));
	$Font = [splice(@ww,$#ww)]->[0];
	$FontPath = join('/',@ww) . '/';
}

@DayNo = qw(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31);
@DayNinzu = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_iPhone = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_iPod = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_iPad = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_AndroidStd = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_AndroidOpera = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_AndroidFirefox = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_WH = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_BB = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Sym = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_IE9 = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_IE10 = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_IE11 = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_IE8 = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_IEOther = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_GC = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Lunascape = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Safari = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Opera = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_bot = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_NMFirefox = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Au = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Doco = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_Softb = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
@Agent_other = qw(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0);
$DayNinzu_num = 0;
$Agent_iPhone_num = 0;
$Agent_iPod_num = 0;
$Agent_iPad_num = 0;
$Agent_AndroidStd_num = 0;
$Agent_AndroidOpera_num = 0;
$Agent_AndroidFirefox_num = 0;
$Agent_WH_num = 0;
$Agent_BB_num = 0;
$Agent_Sym_num = 0;
$Agent_IE9_num = 0;
$Agent_IE10_num = 0;
$Agent_IE11_num = 0;
$Agent_IE8_num = 0;
$Agent_IEOther_num = 0;
$Agent_GC_num = 0;
$Agent_Lunascape_num = 0;
$Agent_Safari_num = 0;
$Agent_Opera_num = 0;
$Agent_bot_num = 0;
$Agent_NMFirefox_num = 0;
$Agent_Au_num = 0;
$Agent_Doco_num = 0;
$Agent_Softb_num = 0;
$Agent_other_num = 0;
#---------------------------
&initgd0; # GD初期化
my $method = $Q->request_method();
if(uc($method) eq 'GET'){
	if($Q->param('act') eq 'disp_grp'){
		$rw = &set_logdata;
		if($rw ne 'ok'){return err_wr("Error\n$rw")}; #Error
		return disp_grp($Q->param('page'));
	}elsif($Q->param('act') eq 'disp_grp_pie'){
		$rw = &set_logdata_pie;
		if($rw ne 'ok'){return err_wr("Error\n$rw")}; #Error
		return disp_grp_pie($Q->param('page'));
	}else{
		return err_wr("Call Error1");
	}
}else{
	return err_wr("Call Error0");
}

}
#************** Sub routines **************
#==================
sub disp_grp_pie($){
my($page)=@_;
my($text1,$gr,@gdata,$gimage,@agent_st);
$text1 = Jcode::jcode("Agent別訪問者数：" . "P". $page . " ")->utf8 . $TITLE . Jcode::jcode(" , $Ya/$Mo , 総訪問者数 = $DayNinzu_num")->utf8;

$gdata[1] = [$Agent_iPhone_num,$Agent_iPod_num,$Agent_iPad_num,
			$Agent_AndroidStd_num,$Agent_AndroidOpera_num,$Agent_AndroidFirefox_num,
			$Agent_WH_num,$Agent_BB_num,$Agent_Sym_num,
			$Agent_IE9_num,$Agent_IE10_num,$Agent_IE11_num,$Agent_IE8_num,$Agent_IEOther_num,
			$Agent_GC_num,$Agent_Lunascape_num,$Agent_Safari_num,$Agent_Opera_num,$Agent_bot_num,$Agent_NMFirefox_num,
			$Agent_Au_num,$Agent_Doco_num,$Agent_Softb_num,$Agent_other_num];
$gr = GD::Graph::pie -> new(800,400);
$gr->set( title => $text1,
		t_margin       => 10,
		pie_height     => 36,
		start_angle    => 230,
		transparent    => 0,
		dclrs   => [ qw(#ff8080 #ff0000 #804040 
					#ffff80 #ff8040 #804000 
					#404040 #808080 #c0c0c0 
					#80ff80 #00ff00 #008000 #808040 #004000 
					#80ffff #004080 #3737ff #000080 #408080 #8080ff 
					#ff80ff #ff00ff #ff0080 #8000ff) ],
		);
$gdata[0] =['iPhone','iPod','iPad',
			'AndroidStd','AndroidOpera','AndroidFirefox',
			'WindowsPhone','BlackBerry','Symbian','IE9','IE10','IE11','IE8','IEOther',
			'GoogleCrome','Lunascape','Safari','Opera','bot','NMFirefox',
			'Au','Doco','Softb','other'];

GD::Text->font_path( "$FontPath" );
#my $fontname = [split(/\./,$Font)]->[0];
my $fontname = $Font;
$gr->set_title_font( "$fontname", 12 );
$gr->set_value_font( "$fontname", 12 );
$gimage = $gr->plot( \@gdata ) or die( "Cannot create image" );

#binmode STDOUT;
# Convert the image to PNG and print it on standard output
#print $gimage->png;
return $gimage->png;
}

#==================
sub disp_grp($){
my($page)=@_;
my($text1,$gr,@gdata,$gimage);
$text1 = Jcode::jcode("Agent別訪問者数：" . "P". $page . " ")->utf8 . $TITLE . ", $Ya/$Mo";

@gdata = (\@DayNo,\@Agent_iPhone,\@Agent_iPod,\@Agent_iPad,
			\@Agent_AndroidStd,\@Agent_AndroidOpera,\@Agent_AndroidFirefox,
			\@Agent_WH,\@Agent_BB,\@Agent_Sym,
			\@Agent_IE9,\@Agent_IE10,\@Agent_IE11,\@Agent_IE8,\@Agent_IEOther,
			\@Agent_GC,\@Agent_Lunascape,\@Agent_Safari,\@Agent_Opera,\@Agent_bot,\@Agent_NMFirefox,
			\@Agent_Au,\@Agent_Doco,\@Agent_Softb,\@Agent_other,\@DayNinzu);

$gr = GD::Graph::mixed -> new(800,600);
$gr->set( title => $text1,
		x_label => Jcode::jcode("［日］")->utf8,
		y_label => Jcode::jcode("人数［人］")->utf8,
		types   => [ qw(bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars bars lines) ],
		dclrs   => [ qw(#ff8080 #ff0000 #804040 
					#ffff80 #ff8040 #804000 
					#000000 #808080 #c0c0c0 
					#80ff80 #00ff00 #008000 #808040 #004000 
					#80ffff #004080 #3737ff #000080 #408080 #8080ff 
					#ff80ff #ff00ff #ff0080 #8000ff #aa0000) ],
		cumulate        => 1,
		y_tick_number => 5,
		y_label_skip =>1,
		bar_width        => 22
		);
$gr->set_legend(iPhone,iPod,iPad,
			AndroidStd,AndroidOpera,AndroidFirefox,
			WindowsPhone,BlackBerry,Symbian,IE9,IE10,IE11,IE8,IEOther,
			GoogleCrome,Lunascape,Safari,Opera,bot,NMFirefox,
			Au,Doco,Softb,other,Total);

GD::Text->font_path( "$FontPath" );
#my $fontname = [split(/\./,$Font)]->[0];
my $fontname = $Font;
$gr->set_title_font( "$fontname", 14 );
$gr->set_legend_font( "$fontname", 8 );
$gr->set_x_axis_font( "$fontname", 8 );
$gr->set_x_label_font( "$fontname", 10 );
$gr->set_y_axis_font( "$fontname", 8 );
$gr->set_y_label_font( "$fontname", 8 );
$gimage = $gr->plot( \@gdata ) or die( "Cannot create image" );

#binmode STDOUT;
# Convert the image to PNG and print it on standard output
#print $gimage->png;
return $gimage->png;
}
#==================
sub set_logdata_pie{
my($text1,$i,@da);
#------------------ログレコード:タブ区切り----------------
# time,get_local_time('all'),user,sex,
# REMOTE_HOST,REMOTE_ADDR,HTTP_X_FORWARDED_FOR,HTTP_CACHE_INFO,
# HTTP_FROM,HTTP_CLIENT_IP,HTTP_SP_HOST,HTTP_CACHE_CONTROL,
# HTTP_X_LOCKING,HTTP_USER_AGENT,HTTP_REFERER,HTTP_VIA,
# HTTP_FORWARDED
#------ファイルから読み込み---------
if (-e $LOGFILE){
	open R,"<$LOGFILE" or die "Cannot Open $LOGFILE :$!"; #読み出し専用
}else{
	return ("Nothing Logfile : " . 'img' . $Ya . '_' . $Mo . '.txt');
}
flock R, $EX_LOCK;
my ($dayw,$mow)=('0','0');
while(<R>){
	chomp($_);
	$_ = Jcode::jcode($_)->euc; # eucにして抽出
	@da = split(/\t/,$_);
	$dayw = Jcode::jcode('日')->euc;
	$mow = Jcode::jcode('月')->euc;
	$i = [split(/$dayw/,[split(/$mow/,$da[1])]->[1])]->[0] - 1;# 日にち抽出→１引いてidexに変換
	++$DayNinzu_num;
	$_ = $da[$UAID]; # User_Agent
	{
		++$Agent_iPhone_num,last if(/iPhone/);
		++$Agent_iPod_num,last if(/iPod/);
		++$Agent_iPad_num,last if(/iPad/);
		++$Agent_AndroidStd_num,last if(/Android.+Safari/);
		++$Agent_AndroidOpera_num,last if(/Android.+Opera/);
		++$Agent_AndroidFirefox_num,last if(/Android.+Firefox/);
		++$Agent_WH_num,last if(/Windows\sPhone/);
		++$Agent_BB_num,last if(/BlackBerry/);
		++$Agent_Sym_num,last if(/Symbian/);
		++$Agent_IE9_num,last if(/MSIE\s9/);
		++$Agent_IE10_num,last if(/MSIE\s10/);
		++$Agent_IE11_num,last if(/Mozilla\/5\.0\s\(Windows\sNT\s6\.3;\sWOW64;\sTrident\/7\.0;\sTouch;\srv:11\.0\)\slike\sGecko/);
		++$Agent_IE8_num,last if(/MSIE\s8/);
		++$Agent_IEOther_num,last if(/MSIE/);
		++$Agent_GC_num,last if(/Chrome/);
		++$Agent_Lunascape_num,last if(/Lunascape/);
		++$Agent_Safari_num,last if(/Safari/);
		++$Agent_Opera_num,last if(/Opera/);
		++$Agent_bot_num,last if(/bot|Bot|slurp|Ask\sJeeves\/Teoma/);
		++$Agent_NMFirefox_num,last if(/Mozilla\/[2-5]|Netscape|Firefox/);
		++$Agent_Au_num,last if(/KDDI/);
		++$Agent_Doco_num,last if(/DoCoMo/);
		++$Agent_Softb_num,last if(/SoftBank|Vodafone/);
		++$Agent_other_num,last;
	}
}
close R;
return 'ok';
}
#==================
sub set_logdata{
my($text1,$i,@da);
#------------------ログレコード:タブ区切り----------------
# time,get_local_time('all'),user,sex,
# REMOTE_HOST,REMOTE_ADDR,HTTP_X_FORWARDED_FOR,HTTP_CACHE_INFO,
# HTTP_FROM,HTTP_CLIENT_IP,HTTP_SP_HOST,HTTP_CACHE_CONTROL,
# HTTP_X_LOCKING,HTTP_USER_AGENT,HTTP_REFERER,HTTP_VIA,
# HTTP_FORWARDED
#------ファイルから読み込み---------
if (-e $LOGFILE){
	open R,"<$LOGFILE" or die "Cannot Open $LOGFILE :$!"; #読み出し専用
}else{
	return ("Nothing Logfile : " . 'img' . $Ya . '_' . $Mo . '.txt');
}
flock R, $EX_LOCK;
my ($dayw,$mow)=('0','0');
while(<R>){
	chomp($_);
	$_ = Jcode::jcode($_)->euc; # eucにして抽出
	@da = split(/\t/,$_);
	$dayw = Jcode::jcode('日')->euc;
	$mow = Jcode::jcode('月')->euc;
	$i = [split(/$dayw/,[split(/$mow/,$da[1])]->[1])]->[0] - 1;# 日にち抽出→１引いてidexに変換
	++$DayNinzu[$i];
	$_ = $da[$UAID]; # User_Agent
	{
		++$Agent_iPhone[$i],last if(/iPhone/);
		++$Agent_iPod[$i],last if(/iPod/);
		++$Agent_iPad[$i],last if(/iPad/);
		++$Agent_AndroidStd[$i],last if(/Android.+Safari/);
		++$Agent_AndroidOpera[$i],last if(/Android.+Opera/);
		++$Agent_AndroidFirefox[$i],last if(/Android.+Firefox/);
		++$Agent_WH[$i],last if(/Windows\sPhone/);
		++$Agent_BB[$i],last if(/BlackBerry/);
		++$Agent_Sym[$i],last if(/Symbian/);
		++$Agent_IE9[$i],last if(/MSIE\s9/);
		++$Agent_IE10[$i],last if(/MSIE\s10/);
		++$Agent_IE11[$i],last if(/Mozilla\/5\.0\s\(Windows\sNT\s6\.3;\sWOW64;\sTrident\/7\.0;\sTouch;\srv:11\.0\)\slike\sGecko/);
		++$Agent_IE8[$i],last if(/MSIE\s8/);
		++$Agent_IEOther[$i],last if(/MSIE/);
		++$Agent_GC[$i],last if(/Chrome/);
		++$Agent_Lunascape[$i],last if(/Lunascape/);
		++$Agent_Safari[$i],last if(/Safari/);
		++$Agent_Opera[$i],last if(/Opera/);
		++$Agent_bot[$i],last if(/bot|Bot|slurp|Ask\sJeeves\/Teoma/);
		++$Agent_NMFirefox[$i],last if(/Mozilla\/[2-5]|Netscape|Firefox/);
		++$Agent_Au[$i],last if(/KDDI/);
		++$Agent_Doco[$i],last if(/DoCoMo/);
		++$Agent_Softb[$i],last if(/SoftBank|Vodafone/);
		++$Agent_other[$i],last;
	}
}
close R;
return 'ok';
}
#==================
sub err_wr($){
my ($d) = @_;
my $font_file =$Q->param('fontfile');
$im->stringFT($BaseCref,         # 色
          $font_file, 10,  # フォント・フォントサイズ
          0,   # 回転角度
          5, 15,     # X・Y 座標
          $d);              # 表示文字列
return $im->png;
}
#==================
sub initgd0{
my($bcolor,$fcolor);
# create a new image
$im = new GD::Image(480,50) || die;
# allocate some colors
$bcolor = $im->colorAllocate(0,0,200);
$fcolor = $im->colorAllocate(0,255,0);
$BaseCref = $im->colorAllocate(255,0,0);
$im->fill(0,0,$fcolor);
$im->rectangle(1,1,480 - 1,50 - 1,$bcolor);
}
#============================================================
sub outst0{
my($x,$y,$text,$col) = @_;
$im->string(gdLargeFont,$x,$y,$text,$col);
# make sure we are writing to a binary stream
#binmode STDOUT;
#print $im->png;
#return;
return $im->png;
}

1;
