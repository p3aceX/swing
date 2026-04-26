package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import com.google.android.recaptcha.RecaptchaAction;
import e1.AbstractC0367g;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLConnection;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzav extends j implements p {
    final /* synthetic */ zzbd zza;
    final /* synthetic */ zzaw zzb;
    final /* synthetic */ RecaptchaAction zzc;
    final /* synthetic */ zzog zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzav(zzbd zzbdVar, zzaw zzawVar, RecaptchaAction recaptchaAction, zzog zzogVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = zzbdVar;
        this.zzb = zzawVar;
        this.zzc = recaptchaAction;
        this.zzd = zzogVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzav(this.zza, this.zzb, this.zzc, this.zzd, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzav) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws zzp {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        zzbb zzbbVarZza = this.zza.zza(zzne.FETCH_TOKEN);
        zzbg zzbgVar = this.zzb.zzi;
        zzbgVar.zze.put(zzbbVarZza, new zzbf(zzbbVarZza, zzbgVar.zza, new zzac()));
        zzob zzobVarZzf = zzoc.zzf();
        zzaw zzawVar = this.zzb;
        zzobVarZzf.zzr(zzawVar.zzg());
        zzobVarZzf.zzd(this.zzc.getAction());
        zzobVarZzf.zzq(zzawVar.zzg.zzI());
        zzobVarZzf.zzp(zzawVar.zzg.zzH());
        zzog zzogVar = this.zzd;
        zzobVarZzf.zzt(zzogVar.zzH());
        zzobVarZzf.zze(zzogVar.zzj());
        zzobVarZzf.zzs(zzogVar.zzI());
        zzoc zzocVar = (zzoc) zzobVarZzf.zzj();
        try {
            URLConnection uRLConnectionOpenConnection = new URL(this.zzb.zzf.zzd()).openConnection();
            J3.i.c(uRLConnectionOpenConnection, "null cannot be cast to non-null type java.net.HttpURLConnection");
            HttpURLConnection httpURLConnection = (HttpURLConnection) uRLConnectionOpenConnection;
            httpURLConnection.setRequestMethod("POST");
            httpURLConnection.setDoOutput(true);
            httpURLConnection.setRequestProperty("Content-Type", "application/x-protobuffer");
            try {
                httpURLConnection.connect();
                zzoi zzoiVarZzf = zzoj.zzf();
                zzoiVarZzf.zzd(zzocVar.zzi());
                zzoiVarZzf.zzq(zzocVar.zzk());
                zzoiVarZzf.zzt(zzocVar.zzI());
                zzoiVarZzf.zzp(zzocVar.zzH());
                zzoiVarZzf.zzr(zzocVar.zzJ());
                zzoiVarZzf.zzs(zzocVar.zzK());
                zzoiVarZzf.zze(zzocVar.zzj());
                httpURLConnection.getOutputStream().write(((zzoj) zzoiVarZzf.zzj()).zzd());
                if (httpURLConnection.getResponseCode() != 200) {
                    throw zzbr.zza(httpURLConnection.getResponseCode());
                }
                try {
                    zzol zzolVarZzg = zzol.zzg(httpURLConnection.getInputStream());
                    this.zzb.zzi.zza(zzbbVarZza);
                    return zzolVarZzg;
                } catch (Exception unused) {
                    throw new zzp(zzn.zzc, zzl.zzR, null);
                }
            } catch (Exception e) {
                if (e instanceof zzp) {
                    throw ((zzp) e);
                }
                throw new zzp(zzn.zze, zzl.zzQ, null);
            }
        } catch (Exception e4) {
            zzp zzpVar = e4 instanceof zzp ? (zzp) e4 : new zzp(zzn.zzc, zzl.zzam, null);
            this.zzb.zzi.zzb(zzbbVarZza, zzpVar, null);
            throw zzpVar;
        }
    }
}
