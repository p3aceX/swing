package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import J3.s;
import Q3.D;
import Q3.F;
import e1.AbstractC0367g;
import java.util.Arrays;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzby extends j implements p {
    final /* synthetic */ Exception zza;
    final /* synthetic */ zzcj zzb;
    final /* synthetic */ zzca zzc;
    private /* synthetic */ Object zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzby(Exception exc, zzcj zzcjVar, zzca zzcaVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = exc;
        this.zzb = zzcjVar;
        this.zzc = zzcaVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        zzby zzbyVar = new zzby(this.zza, this.zzb, this.zzc, interfaceC0762c);
        zzbyVar.zzd = obj;
        return zzbyVar;
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzby) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        zzpg zzpgVarZza;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        D d5 = (D) this.zzd;
        Exception exc = this.zza;
        if (exc instanceof zzae) {
            zzpgVarZza = ((zzae) exc).zza();
            zzpgVarZza.zzd(this.zzb.zza());
        } else {
            zzcj zzcjVar = this.zzb;
            zzpg zzpgVarZzf = zzph.zzf();
            zzpgVarZzf.zzd(zzcjVar.zza());
            zzpgVarZzf.zzp(2);
            zzpgVarZzf.zze(2);
            zzpgVarZza = zzpgVarZzf;
        }
        zzph zzphVar = (zzph) zzpgVarZza.zzj();
        zzphVar.zzk();
        zzphVar.zzj();
        s.a(this.zza.getClass()).b();
        this.zza.getMessage();
        zzcj zzcjVar2 = this.zzb;
        zzz zzzVarZzb = zzcjVar2.zzb();
        zzz zzzVar = zzcjVar2.zza;
        if (zzzVar == null) {
            zzzVar = null;
        }
        zzno zznoVarZza = zzbp.zza(zzzVarZzb, zzzVar);
        String strZzd = this.zzb.zzd();
        if (strZzd.length() == 0) {
            strZzd = "recaptcha.m.Main.rge";
        }
        if (F.q(d5)) {
            zzca zzcaVar = this.zzc;
            zzfy zzfyVarZzh = zzfy.zzh();
            byte[] bArrZzd = zzphVar.zzd();
            String strZzi = zzfyVarZzh.zzi(bArrZzd, 0, bArrZzd.length);
            zzfy zzfyVarZzh2 = zzfy.zzh();
            byte[] bArrZzd2 = zznoVarZza.zzd();
            zzcaVar.zzc.zze().zzb(strZzd, (String[]) Arrays.copyOf(new String[]{strZzi, zzfyVarZzh2.zzi(bArrZzd2, 0, bArrZzd2.length)}, 2));
        }
        return i.f6729a;
    }
}
