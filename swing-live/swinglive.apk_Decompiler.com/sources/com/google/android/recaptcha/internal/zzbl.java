package com.google.android.recaptcha.internal;

import A3.j;
import I3.p;
import Q3.D;
import android.content.ContentValues;
import e1.AbstractC0367g;
import w3.i;
import x3.AbstractC0728h;
import y3.InterfaceC0762c;
import z3.EnumC0789a;

/* JADX INFO: loaded from: classes.dex */
final class zzbl extends j implements p {
    final /* synthetic */ zzbm zza;
    final /* synthetic */ zzpd zzb;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public zzbl(zzbm zzbmVar, zzpd zzpdVar, InterfaceC0762c interfaceC0762c) {
        super(2, interfaceC0762c);
        this.zza = zzbmVar;
        this.zzb = zzpdVar;
    }

    @Override // A3.a
    public final InterfaceC0762c create(Object obj, InterfaceC0762c interfaceC0762c) {
        return new zzbl(this.zza, this.zzb, interfaceC0762c);
    }

    @Override // I3.p
    public final /* bridge */ /* synthetic */ Object invoke(Object obj, Object obj2) {
        return ((zzbl) create((D) obj, (InterfaceC0762c) obj2)).invokeSuspend(i.f6729a);
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        EnumC0789a enumC0789a = EnumC0789a.f6999a;
        AbstractC0367g.M(obj);
        zzbm zzbmVar = this.zza;
        zzpd zzpdVar = this.zzb;
        synchronized (zzbh.class) {
            try {
                if (zzbmVar.zze != null) {
                    byte[] bArrZzd = zzpdVar.zzd();
                    zzba zzbaVar = new zzba(zzfy.zzg().zzi(bArrZzd, 0, bArrZzd.length), System.currentTimeMillis(), 0);
                    zzaz zzazVar = zzbmVar.zze;
                    ContentValues contentValues = new ContentValues();
                    contentValues.put("ss", zzbaVar.zzc());
                    contentValues.put("ts", Long.valueOf(zzbaVar.zzb()));
                    zzazVar.getWritableDatabase().insert("ce", null, contentValues);
                    int iZzb = zzbmVar.zze.zzb() - 500;
                    if (iZzb > 0) {
                        zzbmVar.zze.zza(AbstractC0728h.e0(iZzb, zzbmVar.zze.zzd()));
                    }
                    if (zzbmVar.zze.zzb() >= 20) {
                        zzbmVar.zzg();
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return i.f6729a;
    }
}
