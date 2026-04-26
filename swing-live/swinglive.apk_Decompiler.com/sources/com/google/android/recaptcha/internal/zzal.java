package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import android.app.Application;
import android.os.Build;
import e1.AbstractC0367g;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzal extends j implements p {
    final /* synthetic */ Application zza;
    final /* synthetic */ String zzb;
    final /* synthetic */ zzbd zzc;
    final /* synthetic */ zzbq zzd;
    final /* synthetic */ zzab zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzal(Application application, String str, zzbd zzbdVar, zzbq zzbqVar, zzab zzabVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = application;
        this.zzb = str;
        this.zzc = zzbdVar;
        this.zzd = zzbqVar;
        this.zze = zzabVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzal(this.zza, this.zzb, this.zzc, this.zzd, this.zze, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzal) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws UnsupportedEncodingException {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        zzaf zzafVar = zzaf.zza;
        zzbd zzbdVar = this.zzc;
        Application application = this.zza;
        String strZza = zzaf.zza(application);
        String packageName = application.getPackageName();
        String strZzd = zzbdVar.zzd();
        zzq zzqVar = new zzq(application);
        int i4 = Build.VERSION.SDK_INT;
        String strZza2 = zzqVar.zza("_GRECAPTCHA_KC");
        if (strZza2 == null) {
            strZza2 = "";
        }
        byte[] bytes = ("k=" + URLEncoder.encode(this.zzb, "UTF-8") + "&pk=" + URLEncoder.encode(packageName, "UTF-8") + "&mst=" + URLEncoder.encode(strZza, "UTF-8") + "&msv=" + URLEncoder.encode("18.4.0", "UTF-8") + "&msi=" + URLEncoder.encode(strZzd, "UTF-8") + "&mov=" + i4 + "&mkc=" + strZza2).getBytes(Charset.forName("UTF-8"));
        return this.zzd.zza(this.zze.zzb(), bytes, this.zzc);
    }
}
