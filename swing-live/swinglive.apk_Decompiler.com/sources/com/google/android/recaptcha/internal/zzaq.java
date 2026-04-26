package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import com.google.android.recaptcha.RecaptchaAction;
import e1.AbstractC0367g;
import w3.e;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzaq extends j implements p {
    int zza;
    final /* synthetic */ zzaw zzb;
    final /* synthetic */ RecaptchaAction zzc;
    final /* synthetic */ long zzd;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzaq(zzaw zzawVar, RecaptchaAction recaptchaAction, long j4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzawVar;
        this.zzc = recaptchaAction;
        this.zzd = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzaq(this.zzb, this.zzc, this.zzd, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzaq) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        Object objZzk;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 != 0) {
            objZzk = ((e) obj).f6721a;
        } else {
            zzaw zzawVar = this.zzb;
            RecaptchaAction recaptchaAction = this.zzc;
            long j4 = this.zzd;
            this.zza = 1;
            objZzk = zzawVar.zzk(recaptchaAction, j4, this);
            if (objZzk == enumC0789a) {
                return enumC0789a;
            }
        }
        return new e(objZzk);
    }
}
