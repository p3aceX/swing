package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import com.google.crypto.tink.shaded.protobuf.S;
import g1.f;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import n.b;

/* JADX INFO: loaded from: classes.dex */
public final class zzaec {
    private static final Map<String, zzaeb> zza = new b();
    private static final Map<String, List<WeakReference<zzaee>>> zzb = new b();

    private static String zza(String str, int i4, boolean z4) {
        if (z4) {
            return "http://[" + str + "]:" + i4 + "/";
        }
        return "http://" + str + ":" + i4 + "/";
    }

    public static String zzb(String str) {
        zzaeb zzaebVar;
        Map<String, zzaeb> map = zza;
        synchronized (map) {
            zzaebVar = map.get(str);
        }
        return S.f(zzaebVar != null ? a.m("", zza(zzaebVar.zzb(), zzaebVar.zza(), zzaebVar.zzb().contains(":"))) : "https://", "www.googleapis.com/identitytoolkit/v3/relyingparty");
    }

    public static String zzc(String str) {
        zzaeb zzaebVar;
        Map<String, zzaeb> map = zza;
        synchronized (map) {
            zzaebVar = map.get(str);
        }
        return S.f(zzaebVar != null ? a.m("", zza(zzaebVar.zzb(), zzaebVar.zza(), zzaebVar.zzb().contains(":"))) : "https://", "identitytoolkit.googleapis.com/v2");
    }

    public static String zzd(String str) {
        zzaeb zzaebVar;
        Map<String, zzaeb> map = zza;
        synchronized (map) {
            zzaebVar = map.get(str);
        }
        return S.f(zzaebVar != null ? a.m("", zza(zzaebVar.zzb(), zzaebVar.zza(), zzaebVar.zzb().contains(":"))) : "https://", "securetoken.googleapis.com/v1");
    }

    public static String zza(String str) {
        zzaeb zzaebVar;
        Map<String, zzaeb> map = zza;
        synchronized (map) {
            zzaebVar = map.get(str);
        }
        if (zzaebVar != null) {
            return S.f(zza(zzaebVar.zzb(), zzaebVar.zza(), zzaebVar.zzb().contains(":")), "emulator/auth/handler");
        }
        throw new IllegalStateException("Tried to get the emulator widget endpoint, but no emulator endpoint overrides found.");
    }

    public static void zza(String str, zzaee zzaeeVar) {
        Map<String, List<WeakReference<zzaee>>> map = zzb;
        synchronized (map) {
            try {
                if (map.containsKey(str)) {
                    map.get(str).add(new WeakReference<>(zzaeeVar));
                } else {
                    ArrayList arrayList = new ArrayList();
                    arrayList.add(new WeakReference(zzaeeVar));
                    map.put(str, arrayList);
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }

    public static boolean zza(f fVar) {
        Map<String, zzaeb> map = zza;
        fVar.a();
        return map.containsKey(fVar.f4309c.f4318a);
    }

    public static void zza(f fVar, String str, int i4) {
        fVar.a();
        String str2 = fVar.f4309c.f4318a;
        Map<String, zzaeb> map = zza;
        synchronized (map) {
            map.put(str2, new zzaeb(str, i4));
        }
        Map<String, List<WeakReference<zzaee>>> map2 = zzb;
        synchronized (map2) {
            try {
                if (map2.containsKey(str2)) {
                    Iterator<WeakReference<zzaee>> it = map2.get(str2).iterator();
                    boolean z4 = false;
                    while (it.hasNext()) {
                        zzaee zzaeeVar = it.next().get();
                        if (zzaeeVar != null) {
                            zzaeeVar.zza();
                            z4 = true;
                        }
                    }
                    if (!z4) {
                        zza.remove(str2);
                    }
                }
            } catch (Throwable th) {
                throw th;
            }
        }
    }
}
