package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import Q3.F;
import Q3.I;
import e1.AbstractC0367g;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Iterator;
import java.util.List;
import w3.d;
import w3.e;
import w3.i;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzc extends j implements p {
    int zza;
    final /* synthetic */ zzg zzb;
    final /* synthetic */ String zzc;
    final /* synthetic */ long zzd;
    private /* synthetic */ Object zze;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzc(zzg zzgVar, String str, long j4, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zzb = zzgVar;
        this.zzc = str;
        this.zzd = j4;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        zzc zzcVar = new zzc(this.zzb, this.zzc, this.zzd, interfaceC0762c);
        zzcVar.zze = obj;
        return zzcVar;
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzc) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        int i4 = this.zza;
        AbstractC0367g.M(obj);
        if (i4 == 0) {
            D d5 = (D) this.zze;
            ArrayList arrayList = new ArrayList();
            Iterator it = this.zzb.zzc().iterator();
            while (it.hasNext()) {
                arrayList.add(F.d(d5, new zzb((zza) it.next(), this.zzc, this.zzd, null)));
            }
            I[] iArr = (I[]) arrayList.toArray(new I[0]);
            I[] iArr2 = (I[]) Arrays.copyOf(iArr, iArr.length);
            this.zza = 1;
            obj = F.e(iArr2, this);
            if (obj == enumC0789a) {
                return enumC0789a;
            }
        }
        String str = this.zzc;
        zzof zzofVarZzf = zzog.zzf();
        zzofVarZzf.zzd(str);
        Iterator it2 = ((List) obj).iterator();
        while (it2.hasNext()) {
            Object obj2 = ((e) it2.next()).f6721a;
            if (!(obj2 instanceof d)) {
                zzofVarZzf.zzg((zzog) obj2);
            }
        }
        return (zzog) zzofVarZzf.zzj();
    }
}
