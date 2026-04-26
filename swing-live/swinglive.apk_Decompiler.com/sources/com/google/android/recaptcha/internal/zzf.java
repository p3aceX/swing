package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import J3.r;
import Q3.D;
import Q3.F;
import Q3.I;
import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import w3.e;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzf extends j implements p {
    int zza;
    final /* synthetic */ zzg zzb;
    final /* synthetic */ long zzc;
    final /* synthetic */ zzoe zzd;
    private /* synthetic */ Object zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzf(zzg zzgVar, long j4, zzoe zzoeVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzgVar;
        this.zzc = j4;
        this.zzd = zzoeVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        zzf zzfVar = new zzf(this.zzb, this.zzc, this.zzd, interfaceC0762c);
        zzfVar.zze = obj;
        return zzfVar;
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzf) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        r rVar;
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        if (this.zza != 0) {
            rVar = (r) this.zze;
            AbstractC0367g.M(obj);
        } else {
            AbstractC0367g.M(obj);
            D d5 = (D) this.zze;
            ArrayList arrayList = new ArrayList();
            Iterator it = this.zzb.zzc().iterator();
            while (it.hasNext()) {
                arrayList.add(F.d(d5, new zze((zza) it.next(), this.zzc, this.zzd, null)));
            }
            r rVar2 = new r();
            I[] iArr = (I[]) arrayList.toArray(new I[0]);
            I[] iArr2 = (I[]) Arrays.copyOf(iArr, iArr.length);
            this.zze = rVar2;
            this.zza = 1;
            Object objE = F.e(iArr2, this);
            if (objE == enumC0789a) {
                return enumC0789a;
            }
            rVar = rVar2;
            obj = objE;
        }
        Iterator it2 = ((List) obj).iterator();
        while (it2.hasNext()) {
            Throwable thA = e.a(((e) it2.next()).f6721a);
            if (thA != null) {
                zzp zzpVar = null;
                if (rVar.f832a != null) {
                    zzpVar = new zzp(zzn.zzc, zzl.zzal, null);
                } else if (thA instanceof zzp) {
                    zzpVar = (zzp) thA;
                }
                rVar.f832a = zzpVar;
            }
        }
        zzp zzpVar2 = (zzp) rVar.f832a;
        return new e(zzpVar2 != null ? AbstractC0367g.h(zzpVar2) : i.f6729a);
    }
}
