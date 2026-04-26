package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import e1.AbstractC0367g;
import java.util.Timer;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzbk extends j implements p {
    final /* synthetic */ zzbm zza;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzbk(zzbm zzbmVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = zzbmVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzbk(this.zza, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzbk) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        zzbm zzbmVar = this.zza;
        synchronized (zzbh.class) {
            try {
                zzaz zzazVar = zzbmVar.zze;
                if (zzazVar != null && zzazVar.zzb() == 0) {
                    Timer timer = zzbm.zzb;
                    if (timer != null) {
                        timer.cancel();
                    }
                    zzbm.zzb = null;
                }
                zzbmVar.zzg();
            } catch (Throwable th) {
                throw th;
            }
        }
        return i.f6729a;
    }
}
