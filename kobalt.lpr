program kobalt;
uses crt,mmsystem,sysutils;

type track=record
     notes:array[1..9999] of integer;
     n:integer;
end;

type song=record
     name:string;
     composer:string;
     difficulty:integer;
     old:boolean;
     bestscore:integer;
     musicfile:string;
     scorefile:string;
end;

type footnote=record
     str:string;
     time:integer;
     trackno:integer;
end;

type iarray=array[1..4] of integer;

type iarray2=array[1..6] of integer;

type tarray=array[1..6] of track;

type list=record
     s:array[1..9999] of song;
     n:integer;
     end;

type farray=record
     s:array[1..9999] of footnote;
     n:integer;
end;

function round2(r:real):integer;
begin
     if (r-trunc(r))=0.5 then round2:=trunc(r)+1
     else round2:=round(r);
end;

procedure showDatum(r:song;index:integer);
var temp:string;
begin
     gotoxy(1,index+1);write(r.name);
     str(r.difficulty,temp);
     temp:='Lv.'+temp;
     gotoxy(81-length(temp),index+1);write(temp);
     str(r.bestscore,temp);
     gotoxy(75-length(temp),index+1);write(temp);
end;

procedure showData(r:list;page:integer);
var i,j:integer;
begin
     gotoxy(1,2);
     for i:=1 to 80 do
         for j:=1 to 23 do
             write(' ');
     for i:=1 to 23 do
          if ((page-1)*23+i)<=r.n then
             showDatum(r.s[(page-1)*23+i],i);
end;

procedure initialize(var r:list;var index,page,speed,activation,noofold:integer);
var io:text;
    i,code:integer;
    temp:string;
    key:char;
begin
     assign(io,'data/songlist.dat');
     reset(io);
     r.n:=0;
     noofold:=0;
     readln(io,temp);
     val(temp,activation,code);
     readln(io,temp);
     while not eof(io) do
     begin
          r.n:=r.n+1;
          i:=r.n;
          readln(io,r.s[i].name);
          readln(io,r.s[i].composer);
          readln(io,temp);
          val(temp,r.s[i].difficulty,code);
          readln(io,temp);
          if temp='1' then begin
               r.s[i].old:=true;noofold:=noofold+1;
          end
          else r.s[i].old:=false;
          readln(io,temp);
          val(temp,r.s[i].bestscore,code);
          readln(io,r.s[i].musicfile);
          readln(io,r.s[i].scorefile);
          readln(io,temp);
     end;
     close(io);
     cursoroff;
     gotoxy(11,5);writeln('              .-''''''-.                                       ');
     gotoxy(11,6);writeln('             ''   _    \                      .---.         ');
     gotoxy(11,7);writeln('     .     /   /` ''.   \ /|                  |   |         ');
     gotoxy(11,8);writeln('   .''|    .   |     \  '' ||                  |   |         ');
     gotoxy(11,9);writeln(' .''  |    |   ''      |  ''||                  |   |     .|  ');
     gotoxy(11,10);writeln('<    |    \    \     / / ||  __        __    |   |   .'' |_ ');
     gotoxy(11,11);writeln(' |   | ____`.   ` ..'' /  ||/''__ ''.  .:--.''.  |   | .''     |');
     gotoxy(11,12);writeln(' |   | \ .''   ''-...-''`   |:/`  ''. ''/ |   \ | |   |''--.  .-''');
     gotoxy(11,13);writeln(' |   |/  .               ||     | |`" __ | | |   |   |  |  ');
     gotoxy(11,14);writeln(' |    /\  \              ||\    / '' .''.''''| | |   |   |  |  ');
     gotoxy(11,15);writeln(' |   |  \  \             |/\''..'' / / /   | |_''---''   |  ''.''');
     gotoxy(11,16);writeln(' ''    \  \  \            ''  `''-''`  \ \._,\ ''/        |   / ');
     gotoxy(11,17);writeln('''------''  ''---''                     `--''  `"         `''-''  ');
     index:=1;page:=1;speed:=1;
     gotoxy(31,20);writeln('Ver. 2.0 by Kobe Li');
     gotoxy(27,23);writeln('Press any key to continue...');
     key:=readkey;
end;

procedure savesonglist(r:list;activation:integer);
var io:text;
    i:integer;
begin
     assign(io,'data/songlist.dat');
     rewrite(io);
     writeln(io,activation);
     writeln(io);
     for i:=1 to r.n do
     begin
          writeln(io,r.s[i].name);
          writeln(io,r.s[i].composer);
          writeln(io,r.s[i].difficulty);
          if r.s[i].old then writeln(io,'1')
          else writeln(io,'0');
          writeln(io,r.s[i].bestscore);
          writeln(io,r.s[i].musicfile);
          writeln(io,r.s[i].scorefile);
          writeln(io);
     end;
     close(io);
end;

procedure choosesong(r:list;var index,page,speed:integer;var key:char;activation,noofold:integer);
var prei,prep,i:integer;
    temp:string;
    replay:boolean;
begin
     clrscr;
     gotoxy(1,1);write('Choose song: ');
     if noofold>3 then begin
        temp:=format('%2f',[activation/100]);
        temp:='Activation: '+temp+'%';
        gotoxy(81-length(temp),1);write(temp);
     end;
     showData(r,1);
     prei:=index;prep:=page;replay:=true;
     repeat
           if prep=page then
           begin
                gotoxy(1,prei+1);
                for i:=1 to 80 do write(' ');
                showDatum(r.s[(page-1)*23+prei],prei);
           end
           else showData(r,page);
           gotoxy(1,25);for i:=1 to 79 do write(' ');
           gotoxy(1,1);
           gotoxy(1,25);write('Page ',page,'/',(r.n-1) div 23+1,', ',r.n,' song(s) found');
           temp:='Composer: '+r.s[(page-1)*23+index].composer;
           gotoxy(80-length(temp),25);write(temp);
           textbackground(15);
           textcolor(0);
           gotoxy(1,index+1);
           for i:=1 to 80 do write(' ');
           showDatum(r.s[(page-1)*23+index],index);
           textbackground(0);
           textcolor(7);
           if replay then sndPlaySound(pchar('data/'+r.s[(page-1)*23+index].musicfile),snd_async);
           replay:=false;
           key:=readkey;
           if key=#0 then
           begin
                prei:=index;prep:=page;
                key:=readkey;
                case key of
                     #72:if (index=1)and(page>1) then
                         begin
                              index:=23;page:=page-1;
                              sndPlaySound(pchar(nil),snd_async);
                              replay:=true;
                         end
                         else if index>1 then begin
                              index:=index-1;
                              sndPlaySound(pchar(nil),snd_async);
                              replay:=true;
                         end;
                     #80:if (index=23)and(page<((r.n-1) div 23+1)) then
                         begin
                              index:=1;page:=page+1;
                              sndPlaySound(pchar(nil),snd_async);
                              replay:=true;
                         end
                         else if ((page<>((r.n-1) div 23+1))and(index<23))xor((page=((r.n-1) div 23+1))and(index<((r.n-1) mod 23+1))) then begin
                              index:=index+1;
                              sndPlaySound(pchar(nil),snd_async);
                              replay:=true;
                         end;
                     #73:if page>1 then
                         begin
                              index:=1;page:=page-1;
                              sndPlaySound(pchar(nil),snd_async);
                              replay:=true;
                         end;
                     #81:if page<((r.n-1) div 23+1) then
                         begin
                              index:=1;page:=page+1;
                              sndPlaySound(pchar(nil),snd_async);
                              replay:=true;
                         end;
                end;
           end
           else if key=#13 then
           begin
                gotoxy(60,index+1);write('Speed:',speed);
                repeat
                      key:=readkey;
                      if key=#0 then
                      begin
                           key:=readkey;
                           case key of
                                #72:if speed<9 then
                                begin
                                     speed:=speed+1;
                                     gotoxy(66,index+1);write(speed);
                                end;
                                #80:if speed>1 then
                                begin
                                     speed:=speed-1;
                                     gotoxy(66,index+1);write(speed);
                                end;
                           end;
                      end;
                until (key=#13)or(key=#27);
           end;
     until (key=#13)or(key='e')or(key='E')or(key='a')or(key='A')or(key='m')or(key='M');
     sndPlaySound(pchar(nil),snd_async);
end;

procedure addsong(var songlist:list;num:integer;var key:char);
begin
     clrscr;cursoron;
     if num>songlist.n then songlist.n:=num;
     write('Name: ');readln(songlist.s[num].name);
     write('Difficulty: ');readln(songlist.s[num].difficulty);
     write('Composer: ');readln(songlist.s[num].composer);
     write('Music file: ');readln(songlist.s[num].musicfile);
     write('Score file: ');readln(songlist.s[num].scorefile);
     if num=songlist.n then
     begin
          songlist.s[num].bestscore:=0;
          songlist.s[num].old:=false;
     end;
     cursoroff;key:=#27;
end;

procedure readscore(var tracks:tarray;scorefile:string);
var io:text;
    i,index,code,temp:integer;
    content:string;
begin
     for i:=1 to 6 do tracks[i].n:=0;
     assign(io,scorefile);
     reset(io);
     while not eof(io) do
     begin
          readln(io,content);
          temp:=pos(' ',content);
          val(copy(content,1,temp-1),i,code);
          content:=copy(content,temp+1,length(content)-temp);
          tracks[i].n:=tracks[i].n+1;
          index:=tracks[i].n;
          if pos(' ',content)=0 then val(content,tracks[i].notes[index],code)
          else
          begin
               temp:=pos(' ',content);
               val(copy(content,1,temp-1),tracks[i].notes[index],code);
          end;
     end;
     close(io);
end;

procedure printScene(speed,time:integer;tracks:tarray);
var i,j,dif,re:integer;
begin
     re:=110-10*speed;
     for i:=1 to 6 do
     begin
          for j:=3 to 20 do
          begin
               gotoxy(13*i-5,j);write(' ');
          end;
          for j:=1 to tracks[i].n do
          begin
               dif:=tracks[i].notes[j]-time;
               if dif in [1..(re-1)] then
               begin
                    gotoxy(13*i-5,20-17*dif div re);
                    write('O');
               end;
          end;
     end;
end;

procedure judge(action:char;var tracks:tarray;time,speed:integer;var combo:integer;var score:real;var notescore:iarray;var check:iarray2);
var i,j,total:integer;
begin
     i:=0;
     case action of
          'S','s':i:=1;
          'D','d':i:=2;
          'F','f':i:=3;
          'J','j':i:=4;
          'K','k':i:=5;
          'L','l':i:=6;
     end;
     if (i in [1..6])and(check[i]<=tracks[i].n) then
     begin
          total:=0;
          for j:=1 to 6 do total:=total+tracks[j].n;
          if abs(time-tracks[i].notes[check[i]])<=5 then
          begin
               tracks[i].notes[check[i]]:=-1;
               combo:=combo+1;
               score:=score+900000/total+100000*combo/(total*(total+1)/2);
               check[i]:=check[i]+1;
               notescore[1]:=notescore[1]+1;
               textcolor(11);
               gotoxy(13*i-8,23);write('Perfect');
               textcolor(7);
          end
          else if abs(time-tracks[i].notes[check[i]])<=12 then
          begin
               tracks[i].notes[check[i]]:=-1;
               combo:=combo+1;
               score:=score+900000*0.7/total+100000*combo/(total*(total+1)/2);
               check[i]:=check[i]+1;
               notescore[2]:=notescore[2]+1;
               textcolor(10);
               gotoxy(13*i-8,23);write(' Good  ');
               textcolor(7);
          end
          else if (tracks[i].notes[check[i]]-time)in [1..(110-10*speed)] then
          begin
               tracks[i].notes[check[i]]:=-1;
               combo:=0;
               score:=score+900000*0.3/total;
               check[i]:=check[i]+1;
               notescore[3]:=notescore[3]+1;
               textcolor(13);
               gotoxy(13*i-8,23);write('  Bad  ');
               textcolor(7);
          end;
     end;
end;

procedure drawInterface;
var i,j:integer;
begin
     clrscr;
     gotoxy(1,2);for i:=1 to 80 do write('-');
     gotoxy(1,21);for i:=1 to 80 do write('-');
     for i:=1 to 6 do
         for j:=1 to 4 do
         begin
              gotoxy(13*i-10,21+j);write('|');
         end;
     for i:=1 to 6 do
         for j:=1 to 4 do
         begin
              gotoxy(13*i,21+j);write('|');
         end;
     gotoxy(8,25);write('S');
     gotoxy(21,25);write('D');
     gotoxy(34,25);write('F');
     gotoxy(47,25);write('J');
     gotoxy(60,25);write('K');
     gotoxy(73,25);write('L');
end;

procedure play(r:song;speed:integer;var outscore,maxcombo:integer;var notescore:iarray;var key:char);
var i,j,timepass,combo,precombo,actionno:integer;
    finish:boolean;
    score,prescore:real;
    temp:string;
    tracks:tarray;
    action:string[6];
    check:iarray2;
    init,curr:array[1..4] of word;
begin
     drawInterface;
     gotoxy(1,1);write(r.name);
     combo:=0;precombo:=0;maxcombo:=0;score:=0;prescore:=0;
     gotoxy(37,1);write('Combo:0');
     gotoxy(68,1);write('Score:0000000');
     for i:=1 to 4 do notescore[i]:=0;
     key:=' ';
     delay(2000);
     readscore(tracks,'data/'+r.scorefile);
     for i:=1 to 6 do check[i]:=1;
     DecodeTime(time,init[1],init[2],init[3],init[4]);
     repeat
           DecodeTime(time,curr[1],curr[2],curr[3],curr[4]);
           timepass:=10*speed-110+((curr[2]-init[2])*60000+(curr[3]-init[3])*1000+curr[4]-init[4])div 20;
           if timepass=0 then sndPlaySound(pchar('data/'+r.musicfile),snd_async);
           printScene(speed,timepass,tracks);
           for i:=1 to 6 do
                if ((timepass-tracks[i].notes[check[i]])>12)and(tracks[i].notes[check[i]]<>-1)and(check[i]<=tracks[i].n) then
                begin
                     tracks[i].notes[check[i]]:=-1;
                     combo:=0;
                     check[i]:=check[i]+1;
                     notescore[4]:=notescore[4]+1;
                     gotoxy(13*i-8,23);write(' Miss  ');
                end;
           if keypressed then
           begin
                actionno:=0;
                repeat
                      actionno:=actionno+1;
                      action[actionno]:=readkey;
                until not keypressed;
                for i:=1 to actionno do
                    if action[i]<>#27 then judge(action[i],tracks,timepass,speed,combo,score,notescore,check)
                    else key:=action[i];
                if combo>maxcombo then maxcombo:=combo;
           end;
           gotoxy(43,1);
           if precombo<>combo then
           begin
                for i:=1 to 4 do write(' ');
                gotoxy(43,1);write(combo);
                precombo:=combo;
           end;
           if prescore<>score then
           begin
                str(round2(score),temp);
                gotoxy(81-length(temp),1);write(temp);
                prescore:=score;
           end;
           finish:=true;
           for i:=1 to 6 do
               if check[i]<=tracks[i].n then finish:=false;
     until (key=#27)or finish;
     gotoxy(1,3);
     for i:=1 to 80 do
         for j:=3 to 20 do write(' ');
     if key<>#27 then delay(2000);
     outscore:=round2(score);
     sndPlaySound(pchar(nil),snd_async);
end;

procedure showres(var r:song;score,combo:integer;notescore:iarray;var activation,noofold:integer);
var key:char;
    a:integer;
    res:string;
begin
     if noofold>3 then a:=1
     else a:=0;
     gotoxy(33,5-a);
     write('Perfect: ',notescore[1]);
     delay(1000);
     gotoxy(36,7-a);
     write('Good: ',notescore[2]);
     delay(1000);
     gotoxy(37,9-a);
     write('Bad: ',notescore[3]);
     delay(1000);
     gotoxy(36,11-a);
     write('Miss: ',notescore[4]);
     delay(1000);
     gotoxy(31,13-a);
     write('Max Combo: ',combo);
     delay(1000);
     gotoxy(35,15-a);
     write('Score: ',score);
     if score>r.bestscore then begin
          r.bestscore:=score;
          textcolor(10);
          write(' New Best!');
          textcolor(7);
     end;
     delay(1000);
     case score of
          1000000:key:='Z';
          900000..999999:key:='S';
          800000..899999:key:='A';
          700000..799999:key:='B';
          600000..699999:key:='C';
          else key:='D';
     end;
     gotoxy(36,16);
     write('Rank: ',key);
     if noofold>3 then
     begin
          delay(1000);
          a:=round2(score/10000);
          if not r.old then begin
             a:=a+100;
             r.old:=true;
             noofold:=noofold+1;
          end;
          if activation+a>10000 then a:=10000-activation;
          res:='Activation: '+format('%2f',[activation/100])+'% + '+format('%2f',[a/100])+'% = '+format('%2f',[(activation+a)/100])+'%';
          gotoxy(30,18);write(res);
          activation:=activation+a;
     end;
     if keypressed then
        repeat
              key:=readkey;
        until not keypressed;
     key:=readkey;
end;

function getDif(realtime:real;basetime,scale:integer):integer;
begin
     getDif:=(round2(realtime)-basetime-1) div scale+1;
     if round2(realtime)<=(basetime+scale-((basetime-1) mod scale)-1) then getDif:=0;
     if round2(realtime)<=(basetime-((basetime-1) mod scale)-1) then getDif:=-1;
end;

procedure writeHeader(r:song;realtime:real;bpm:integer);
var sec,i:integer;
begin
     gotoxy(1,1);
     for i:=1 to 80 do write(' ');
     gotoxy(1,1);write(r.name);
     sec:=round2(realtime/50);
     gotoxy(37,1);write(format('%.2d',[sec div 3600]),':',format('%.2d',[(sec mod 3600) div 60]),
                                          ':',format('%.2d',[sec mod 60]));
     gotoxy(73,1);write('BPM:',bpm);
end;

procedure askBPM(var bpm:integer);
var temp:string;
    key:char;
    code:integer;
begin
     cursoron;
     if bpm=0 then temp:=''
     else str(bpm,temp);
     gotoxy(77,1);write(temp);
     repeat
           key:=readkey;
           if (ord(key) in [48..57])and(length(temp)<3) then
           begin
                temp:=temp+key;
                write(key);
           end
           else if (key=#8)and(length(temp)>0) then
           begin
                gotoxy(76+length(temp),1);write(' ');
                gotoxy(76+length(temp),1);
                temp:=copy(temp,1,length(temp)-1);

           end;
     until key=#13;
     val(temp,bpm,code);
     cursoroff;
end;

procedure readScore_Edit(var tracks:tarray;var footnotes:farray;scorefile:string);
var io:text;
    i,index,index2,code,temp:integer;
    content:string;
begin
     for i:=1 to 6 do tracks[i].n:=0;
     footnotes.n:=0;
     assign(io,scorefile);
     reset(io);
     while not eof(io) do
     begin
          readln(io,content);
          temp:=pos(' ',content);
          val(copy(content,1,temp-1),i,code);
          content:=copy(content,temp+1,length(content)-temp);
          tracks[i].n:=tracks[i].n+1;
          index:=tracks[i].n;
          if pos(' ',content)=0 then val(content,tracks[i].notes[index],code)
          else
          begin
               temp:=pos(' ',content);
               val(copy(content,1,temp-1),tracks[i].notes[index],code);
               footnotes.n:=footnotes.n+1;
               index2:=footnotes.n;
               footnotes.s[index2].str:=copy(content,temp+1,length(content)-temp);
               footnotes.s[index2].time:=tracks[i].notes[index];
               footnotes.s[index2].trackno:=i;
          end;
     end;
     close(io);
end;

procedure printScene_Edit(basetime,scale:integer;tracks:tarray;footnotes:farray);
var i,j,dif:integer;
begin
     for i:=1 to 7 do
         for j:=3 to 20 do
         begin
              gotoxy(i,j);write(' ');
         end;
     basetime:=basetime+scale-((basetime-1) mod scale)-1;
     for i:=3 to 20 do
     begin
          gotoxy(1,i);write(basetime+(20-i)*scale);
          gotoxy(79,i);write(' ');
     end;
     for i:=1 to 6 do
     begin
          for j:=3 to 20 do
          begin
               gotoxy(13*i-5,j);write(' ');
          end;
          for j:=1 to tracks[i].n do
          begin
               dif:=getDif(tracks[i].notes[j],basetime,scale);
               if dif in [0..17] then
               begin
                    gotoxy(13*i-5,20-dif);
                    write('O');
               end;
          end;
     end;
     for i:=1 to footnotes.n do
     begin
          dif:=getDif(footnotes.s[i].time,basetime,scale);
          if dif in [0..17] then
          begin
               gotoxy(79,20-dif);
               write(footnotes.s[i].trackno);
          end;
     end;
end;

procedure addOrDropNote(var tracks:tarray;footnotes:farray;key:char;realtime:real;scale:integer);
var i,j,index,index2,trackno,lower,upper:integer;
    exist,valid:boolean;
begin
     case key of
          'S','s':trackno:=1;
          'D','d':trackno:=2;
          'F','f':trackno:=3;
          'J','j':trackno:=4;
          'K','k':trackno:=5;
          'L','l':trackno:=6;
     end;
     exist:=false;i:=0;
     while not exist and (i<tracks[trackno].n) do
     begin
          i:=i+1;
          lower:=((round2(realtime)-1) div scale)*scale+1;
          upper:=((round2(realtime)-1) div scale+1)*scale;
          if (tracks[trackno].notes[i]>=lower)and(tracks[trackno].notes[i]<=upper) then exist:=true;
     end;
     if exist then begin
          valid:=true;index2:=0;
          while valid and (index2<footnotes.n) do
          begin
               index2:=index2+1;
               lower:=((round2(realtime)-1) div scale)*scale+1;
               upper:=((round2(realtime)-1) div scale+1)*scale;
               if (footnotes.s[index2].time>=lower)and(footnotes.s[index2].time<=upper)and(footnotes.s[index2].trackno=trackno) then valid:=false;
          end;
          if valid then begin
             for j:=i to (tracks[trackno].n-1) do
                 tracks[trackno].notes[j]:=tracks[trackno].notes[j+1];
             tracks[trackno].n:=tracks[trackno].n-1;
          end;
     end
     else begin
          tracks[trackno].n:=tracks[trackno].n+1;
          index:=tracks[trackno].n;
          tracks[trackno].notes[index]:=round2(realtime);
     end;
end;

procedure modifyFootnote(var footnotes:farray;tracks:tarray;realtime:real;basetime,scale:integer);
var i,index,trackno,dif:integer;
    note:string;
    exist,valid,empty:boolean;
    key:char;
begin
     exist:=false;index:=0;valid:=false;empty:=false;
     dif:=getDif(realtime,basetime,scale);
     gotoxy(1,1);
     repeat
           index:=index+1;
           if footnotes.s[index].time=round2(realtime) then exist:=true;
     until exist or (index=footnotes.n);
     if exist then begin
          note:=footnotes.s[index].str;trackno:=footnotes.s[index].trackno;
     end
     else begin
          note:='';trackno:=1;empty:=true;
     end;
     gotoxy(1,1);
     for i:=1 to 80 do write(' ');
     gotoxy(1,1);write(note);
     cursoron;
     repeat
           if (not exist)and empty then key:=#13
           else key:=readkey;
           case key of
                #0:begin
                        key:=readkey;
                        if (key=#75)and(trackno>1) then begin
                           trackno:=trackno-1;
                           gotoxy(79,20-dif);write(trackno);
                           gotoxy(length(note)+1,1);
                        end
                        else if (key=#77)and(trackno<6) then begin
                             trackno:=trackno+1;
                             gotoxy(79,20-dif);write(trackno);
                             gotoxy(length(note)+1,1);
                        end;
                end;
                #8:if length(note)>0 then begin
                      gotoxy(length(note),1);write(' ');
                      gotoxy(length(note),1);
                      note:=copy(note,1,length(note)-1);
                end;
                #13:begin
                         valid:=false;i:=0;
                         repeat
                               i:=i+1;
                               if tracks[trackno].notes[i]=round2(realtime) then valid:=true;
                         until valid or (i=tracks[trackno].n);
                         if not exist then begin
                              if valid and empty then begin
                                   empty:=false;
                                   gotoxy(79,20-dif);write(trackno);
                                   gotoxy(1,1);
                                   valid:=false;
                              end
                              else if empty then begin
                                   if trackno<6 then trackno:=trackno+1
                                   else valid:=true;
                              end;
                         end;
                end;
                else if length(note)<79 then begin
                        write(key);
                        note:=note+key;
                end;
           end;
     until valid;
     if exist then begin
          if length(note)>0 then begin
             footnotes.s[index].str:=note;
             footnotes.s[index].trackno:=trackno;
          end
          else begin
               for i:=index to (footnotes.n-1) do
                   footnotes.s[i]:=footnotes.s[i+1];
               footnotes.n:=footnotes.n-1;
          end;
     end
     else begin
              if (not empty)and(length(note)>0) then begin
                 footnotes.n:=footnotes.n+1;
                 index:=footnotes.n;
                 footnotes.s[index].str:=note;
                 footnotes.s[index].time:=round2(realtime);
                 footnotes.s[index].trackno:=trackno;
              end;
     end;
     cursoroff;
end;

procedure copyScore(var tracks:tarray;var realtime:real;var basetime,scale:integer);
var i,j,k,s,e,ps,pe,dif,code,pofs,index:integer;
    key:char;
    str,prestr:string;
    valid:boolean;
begin
     valid:=false;
     dif:=getDif(realtime,basetime,scale);
     str:='';
     gotoxy(1,1);
     for i:=1 to 80 do write(' ');
     gotoxy(1,1);
     cursoron;
     repeat
           key:=readkey;
           if (key=#8)and(length(str)>0) then begin
              gotoxy(length(str),1);write(' ');
              gotoxy(length(str),1);
              str:=copy(str,1,length(str)-1);
           end
           else if key=#13 then begin
              prestr:=str;
              valid:=true;
              pofs:=pos(' ',str);
              if pofs=0 then valid:=false;
              val(copy(str,1,pofs-1),s,code);
              if code>0 then valid:=false;
              str:=copy(str,pofs+1,length(str)-pofs);
              pofs:=pos(' ',str);
              if pofs=0 then valid:=false;
              val(copy(str,1,pofs-1),e,code);
              if code>0 then valid:=false;
              str:=copy(str,pofs+1,length(str)-pofs);
              val(str,ps,code);
              if code>0 then valid:=false;
              if (s>e)or((ps<=e)and(ps>=s)) then valid:=false;
              str:=prestr;
           end
           else if length(str)<79 then begin
                write(key);
                str:=str+key;
           end;
     until (valid)or(key=#27);
     cursoroff;
     if key<>#27 then begin
        pe:=ps-s+e;
        for i:=1 to 6 do begin
            j:=0;
            repeat
                  j:=j+1;
                  if (tracks[i].notes[j]>=ps)and(tracks[i].notes[j]<=pe) then begin
                     for k:=j to (tracks[i].n-1) do
                         tracks[i].notes[k]:=tracks[i].notes[k+1];
                     tracks[i].n:=tracks[i].n-1;
                     j:=j-1;
                  end;
            until j=tracks[i].n;
            for j:=1 to tracks[i].n do
                if (tracks[i].notes[j]>=s)and(tracks[i].notes[j]<=e) then begin
                   tracks[i].n:=tracks[i].n+1;
                   index:=tracks[i].n;
                   tracks[i].notes[index]:=tracks[i].notes[j]+ps-s;
                end;
        end;
        realtime:=ps;
        basetime:=round2(realtime)-dif*scale;
     end;
end;

procedure deleteScore(var tracks:tarray;var realtime:real;var basetime,scale:integer);
var i,j,k,s,e,code,dif,pofs:integer;
    key:char;
    str,prestr:string;
    valid:boolean;
begin
     valid:=false;
     dif:=getDif(realtime,basetime,scale);
     str:='';
     gotoxy(1,1);
     for i:=1 to 80 do write(' ');
     gotoxy(1,1);
     cursoron;
     repeat
           key:=readkey;
           if (key=#8)and(length(str)>0) then begin
              gotoxy(length(str),1);write(' ');
              gotoxy(length(str),1);
              str:=copy(str,1,length(str)-1);
           end
           else if key=#13 then begin
              prestr:=str;
              valid:=true;
              pofs:=pos(' ',str);
              if pofs=0 then valid:=false;
              val(copy(str,1,pofs-1),s,code);
              if code>0 then valid:=false;
              str:=copy(str,pofs+1,length(str)-pofs);
              val(str,e,code);
              if code>0 then valid:=false;
              if s>e then valid:=false;
              str:=prestr;
           end
           else if length(str)<79 then begin
                write(key);
                str:=str+key;
           end;
     until (valid)or(key=#27);
     cursoroff;
     if key<>#27 then begin
        for i:=1 to 6 do begin
            j:=0;
            repeat
                  j:=j+1;
                  if (tracks[i].notes[j]>=s)and(tracks[i].notes[j]<=e) then begin
                     for k:=j to (tracks[i].n-1) do
                         tracks[i].notes[k]:=tracks[i].notes[k+1];
                     tracks[i].n:=tracks[i].n-1;
                     j:=j-1;
                  end;
            until j=tracks[i].n;
        end;
     end;
     realtime:=s;
     basetime:=round2(realtime)-dif*scale;
end;

procedure save(var tracks:tarray;var footnotes:farray;scorefile:string);
var i,j,k,tempn,min:integer;
    p:array[1..7] of integer;
    tempf:footnote;
    io:text;
begin
     for i:=1 to 6 do
         for j:=1 to tracks[i].n do
             for k:=1 to tracks[i].n-j do
                 if tracks[i].notes[k]>tracks[i].notes[k+1] then begin
                    tempn:=tracks[i].notes[k];
                    tracks[i].notes[k]:=tracks[i].notes[k+1];
                    tracks[i].notes[k+1]:=tempn;
                 end;
     for j:=1 to footnotes.n do
         for k:=1 to footnotes.n-j do
             if footnotes.s[k].time>footnotes.s[k+1].time then begin
                tempf:=footnotes.s[k];
                footnotes.s[k]:=footnotes.s[k+1];
                footnotes.s[k+1]:=tempf;
             end;
     for i:=1 to 7 do p[i]:=1;
     assign(io,scorefile);
     rewrite(io);
     while (p[1]<=tracks[1].n)or(p[2]<=tracks[2].n)or(p[3]<=tracks[3].n)or(p[4]<=tracks[4].n)
           or(p[5]<=tracks[5].n)or(p[6]<=tracks[6].n)or(p[7]<=footnotes.n) do
     begin
           min:=7;
           repeat
                 min:=min-1;
           until p[min]<=tracks[min].n;
           for i:=min downto 1 do
               if (tracks[i].notes[p[i]]<=tracks[min].notes[p[min]])and(p[i]<=tracks[i].n) then min:=i;
           if (footnotes.s[p[7]].time=tracks[min].notes[p[min]])and(footnotes.s[p[7]].trackno=min)
              and(p[7]<=footnotes.n) then begin
              writeln(io,min,' ',tracks[min].notes[p[min]],' ',footnotes.s[p[7]].str);
              p[7]:=p[7]+1;
           end
           else writeln(io,min,' ',tracks[min].notes[p[min]]);
           p[min]:=p[min]+1;
     end;
     close(io);
end;

procedure edit(r:song;var key:char);
var i,basetime,bpm,beat,dif,sec,scale:integer;
    realtime:real;
    tracks:tarray;
    footnotes:farray;
begin
     drawInterface;
     gotoxy(1,1);write(r.name);
     gotoxy(37,1);write('00:00:00');
     gotoxy(73,1);write('BPM:');
     bpm:=0;
     askBPM(bpm);
     basetime:=1;realtime:=1;scale:=1;
     readScore_Edit(tracks,footnotes,'data/'+r.scorefile);
     printScene_Edit(1,scale,tracks,footnotes);
     gotoxy(9,20);
     for i:=9 to 78 do
         if i mod 13<>8 then write('-')
         else gotoxy(i+1,20);
     gotoxy(80,20);write('<');
     repeat
           key:=readkey;
           case key of
                's','S','d','D','f','F','j','J','k','K','l','L':begin
                     addOrDropNote(tracks,footnotes,key,realtime,scale);
                     printScene_Edit(basetime,scale,tracks,footnotes);
                end;
                '1'..'9':begin
                     beat:=ord(key)-48;
                     dif:=getDif(realtime,basetime,scale);
                     realtime:=realtime+3000/bpm/beat;
                     basetime:=round2(realtime)-dif*scale;
                     printScene_Edit(basetime,scale,tracks,footnotes);
                     sec:=round2(realtime/50);
                     gotoxy(37,1);write(format('%.2d',[sec div 3600]),':',format('%.2d',[(sec mod 3600) div 60]),
                                                          ':',format('%.2d',[sec mod 60]));
                end;
                'b','B':askBPM(bpm);
                'n','N':begin
                     modifyFootnote(footnotes,tracks,realtime,basetime,scale);
                     printScene_Edit(basetime,scale,tracks,footnotes);
                     writeHeader(r,realtime,bpm);
                end;
                'c','C':begin
                     copyScore(tracks,realtime,basetime,scale);
                     printScene_Edit(basetime,scale,tracks,footnotes);
                     writeHeader(r,realtime,bpm);
                end;
                'x','X':begin
                     deleteScore(tracks,realtime,basetime,scale);
                     printScene_Edit(basetime,scale,tracks,footnotes);
                     writeHeader(r,realtime,bpm);
                end;
                'v','V':begin
                     save(tracks,footnotes,'data/'+r.scorefile);
                     gotoxy(1,1);
                     for i:=1 to 80 do write(' ');
                     gotoxy(38,1);write('Saved!');
                     delay(1000);
                     writeHeader(r,realtime,bpm);
                end;
                #27:begin
                     gotoxy(1,1);
                     for i:=1 to 80 do write(' ');
                     gotoxy(31,1);write('Save? (Y/N/Cancel C)');
                     if keypressed then
                        repeat
                              key:=readkey;
                        until not keypressed;
                     repeat
                           key:=readkey;
                     until (key='y')or(key='Y')or(key='n')or(key='N')or(key='c')or(key='C');
                     if (key='y')or(key='Y') then
                          save(tracks,footnotes,'data/'+r.scorefile);
                     if (key='y')or(key='Y')or(key='n')or(key='N') then key:=#27
                     else writeHeader(r,realtime,bpm);
                end;
                #0:begin
                     key:=readkey;
                     if key=#72 then
                     begin
                          realtime:=realtime+scale;
                          if getDif(realtime,basetime,scale)=18 then begin
                               basetime:=basetime+scale;
                               printScene_Edit(basetime,scale,tracks,footnotes);
                          end
                          else begin
                               dif:=getDif(realtime,basetime,scale);
                               gotoxy(9,20-dif);
                               for i:=9 to 78 do
                                   if i mod 13<>8 then write('-')
                                   else gotoxy(i+1,20-dif);
                               gotoxy(80,20-dif);write('<');
                               gotoxy(9,21-dif);
                               for i:=9 to 78 do
                                   if i mod 13<>8 then write(' ')
                                   else gotoxy(i+1,21-dif);
                               gotoxy(80,21-dif);write(' ');
                          end;
                          sec:=round2(realtime/50);
                          gotoxy(37,1);write(format('%.2d',[sec div 3600]),':',format('%.2d',[(sec mod 3600) div 60]),
                                                          ':',format('%.2d',[sec mod 60]));
                     end
                     else if (key=#80)and(round2(realtime)>scale) then
                     begin
                          realtime:=realtime-scale;
                          if getDif(realtime,basetime,scale)<0 then begin
                               basetime:=basetime-scale;
                               printScene_Edit(basetime,scale,tracks,footnotes);
                          end
                          else begin
                               dif:=getDif(realtime,basetime,scale);
                               gotoxy(9,20-dif);
                               for i:=9 to 78 do
                                   if i mod 13<>8 then write('-')
                                   else gotoxy(i+1,20-dif);
                               gotoxy(80,20-dif);write('<');
                               gotoxy(9,19-dif);
                               for i:=9 to 78 do
                                   if i mod 13<>8 then write(' ')
                                   else gotoxy(i+1,19-dif);
                               gotoxy(80,19-dif);write(' ');
                          end;
                          sec:=round2(realtime/50);
                          gotoxy(37,1);write(format('%.2d',[sec div 3600]),':',format('%.2d',[(sec mod 3600) div 60]),
                                                          ':',format('%.2d',[sec mod 60]));
                     end
                     else case key of
                          #2..#10:begin
                               beat:=ord(key)-1;
                               dif:=getDif(realtime,basetime,scale);
                               realtime:=realtime-3000/bpm/beat;
                               if (round2(realtime)-dif*scale)>=1 then
                               begin
                                    basetime:=round2(realtime)-dif*scale;
                                    printScene_Edit(basetime,scale,tracks,footnotes);
                                    sec:=round2(realtime/50);
                                    gotoxy(37,1);write(format('%.2d',[sec div 3600]),':',format('%.2d',[(sec mod 3600) div 60]),
                                                          ':',format('%.2d',[sec mod 60]));
                               end
                               else realtime:=realtime+3000/bpm/beat;
                          end;
                          #59..#67:begin
                               dif:=getDif(realtime,basetime,scale);
                               scale:=ord(key)-58;
                               basetime:=round2(realtime)-dif*scale;
                               if basetime<1 then begin
                                    basetime:=scale;
                                    for i:=3 to 20 do begin
                                         gotoxy(80,i);write(' ');
                                    end;
                                    dif:=getDif(realtime,basetime,scale);
                                    gotoxy(9,20-dif);
                                    for i:=9 to 79 do
                                        if i mod 13<>8 then write('-')
                                        else gotoxy(i+1,20-dif);
                                    gotoxy(80,20-dif);write('<');
                               end;
                               printScene_Edit(basetime,scale,tracks,footnotes);
                          end;
                     end;
                end;
           end;
     until key=#27;
end;

var songlist:list;
    index,page,score,combo,speed,activation,noofold:integer;
    notescore:iarray;
    key:char;
begin
     initialize(songlist,index,page,speed,activation,noofold);
     repeat
           choosesong(songlist,index,page,speed,key,activation,noofold);
           if key=#13 then play(songlist.s[(page-1)*23+index],speed,score,combo,notescore,key)
           else if (key='e')or(key='E') then edit(songlist.s[(page-1)*23+index],key)
           else if (key='a')or(key='A') then addsong(songlist,songlist.n+1,key)
           else if (key='m')or(key='M') then addsong(songlist,(page-1)*23+index,key);
           savesonglist(songlist,activation);
           if key=#27 then continue;
           showres(songlist.s[(page-1)*23+index],score,combo,notescore,activation,noofold);
     until false;
end.
