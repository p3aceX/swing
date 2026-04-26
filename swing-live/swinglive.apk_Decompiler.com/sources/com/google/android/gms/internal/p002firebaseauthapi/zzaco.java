package com.google.android.gms.internal.p002firebaseauthapi;

import B1.a;
import java.lang.reflect.Type;

/* JADX INFO: loaded from: classes.dex */
public class zzaco {
    private static final String zza = "com.google.android.gms.internal.firebase-auth-api.zzaco";

    private zzaco() {
    }

    public static Object zza(String str, Type type) throws zzaah {
        if (type != String.class) {
            if (type == Void.class) {
                return null;
            }
            try {
                try {
                    return ((zzacq) ((Class) type).getConstructor(new Class[0]).newInstance(new Object[0])).zza(str);
                } catch (Exception e) {
                    throw new zzaah(a.m("Json conversion failed! ", e.getMessage()), e);
                }
            } catch (Exception e4) {
                throw new zzaah("Instantiation of JsonResponse failed! ".concat(String.valueOf(type)), e4);
            }
        }
        try {
            zzaek zzaekVar = (zzaek) new zzaek().zza(str);
            if (zzaekVar.zzb()) {
                return zzaekVar.zza();
            }
            throw new zzaah("No error message: " + str);
        } catch (Exception e5) {
            throw new zzaah(a.m("Json conversion failed! ", e5.getMessage()), e5);
        }
    }
}
