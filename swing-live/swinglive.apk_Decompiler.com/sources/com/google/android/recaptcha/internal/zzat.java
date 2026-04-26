package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import Q3.F;
import com.google.android.recaptcha.RecaptchaAction;
import e1.AbstractC0367g;
import w3.e;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzat extends j implements p {
    int zza;
    final /* synthetic */ zzaw zzb;
    final /* synthetic */ long zzc;
    final /* synthetic */ RecaptchaAction zzd;
    final /* synthetic */ zzbd zze;
    final /* synthetic */ String zzf;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzat(zzaw zzawVar, long j4, RecaptchaAction recaptchaAction, zzbd zzbdVar, String str, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzawVar;
        this.zzc = j4;
        this.zzd = recaptchaAction;
        this.zze = zzbdVar;
        this.zzf = str;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzat(this.zzb, this.zzc, this.zzd, this.zze, this.zzf, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzat) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) throws Throwable {
        zzat zzatVar;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            zzatVar = this;
            if (i4 == 1) {
            }
            zzol zzolVar = (zzol) obj;
            zzatVar.zzb.zzl(zzolVar, zzatVar.zze);
            zzatVar.zzb.zzi.zza(zzatVar.zze.zza(zzne.EXECUTE_TOTAL));
            return new e(zzolVar.zzi());
        }
        zzaw.zzi(this.zzb, this.zzc, this.zzd, this.zze);
        zzaw zzawVar = this.zzb;
        long j4 = this.zzc;
        String str = this.zzf;
        zzbd zzbdVar = this.zze;
        this.zza = 1;
        zzatVar = this;
        obj = zzawVar.zzj(j4, str, zzbdVar, zzatVar);
        if (obj == enumC0789a) {
            return enumC0789a;
        }
        zzaw zzawVar2 = zzatVar.zzb;
        RecaptchaAction recaptchaAction = zzatVar.zzd;
        zzatVar.zza = 2;
        obj = F.B(zzawVar2.zzl.zza().n(), new zzav(zzatVar.zze, zzawVar2, recaptchaAction, (zzog) obj, null), this);
        if (obj == enumC0789a) {
            return enumC0789a;
        }
        zzol zzolVar2 = (zzol) obj;
        zzatVar.zzb.zzl(zzolVar2, zzatVar.zze);
        zzatVar.zzb.zzi.zza(zzatVar.zze.zza(zzne.EXECUTE_TOTAL));
        return new e(zzolVar2.zzi());
    }
}
