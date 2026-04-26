package com.google.android.recaptcha.internal;

import J3.i;
import M3.b;
import M3.c;
import P3.m;
import android.content.Context;
import java.io.File;
import java.io.IOException;
import java.lang.reflect.InvocationTargetException;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import x3.AbstractC0728h;
import x3.AbstractC0730j;

/* JADX INFO: loaded from: classes.dex */
public final class zzy implements zzh {
    private final Context zza;
    private final String zzb = "rce_";
    private final zzad zzc;

    public zzy(Context context) {
        this.zza = context;
        this.zzc = new zzad(context);
    }

    @Override // com.google.android.recaptcha.internal.zzh
    public final String zza(String str) {
        File file = new File(this.zza.getCacheDir(), this.zzb.concat(String.valueOf(str)));
        if (file.exists()) {
            return new String(zzad.zza(file), StandardCharsets.UTF_8);
        }
        return null;
    }

    @Override // com.google.android.recaptcha.internal.zzh
    public final void zzb() {
        try {
            File[] fileArrListFiles = this.zza.getCacheDir().listFiles();
            if (fileArrListFiles != null) {
                ArrayList arrayList = new ArrayList();
                for (File file : fileArrListFiles) {
                    if (m.F0(file.getName(), this.zzb)) {
                        arrayList.add(file);
                    }
                }
                Iterator it = arrayList.iterator();
                while (it.hasNext()) {
                    ((File) it.next()).delete();
                }
            }
        } catch (Exception unused) {
        }
    }

    @Override // com.google.android.recaptcha.internal.zzh
    public final void zzc(String str, String str2) throws IllegalAccessException, IOException, InvocationTargetException {
        c cVar = new c('A', 'z');
        ArrayList arrayList = new ArrayList(AbstractC0730j.V(cVar));
        Iterator it = cVar.iterator();
        while (((b) it).f1093c) {
            b bVar = (b) it;
            int i4 = bVar.f1094d;
            if (i4 != bVar.f1092b) {
                bVar.f1094d = bVar.f1091a + i4;
            } else {
                if (!bVar.f1093c) {
                    throw new NoSuchElementException();
                }
                bVar.f1093c = false;
            }
            arrayList.add(Character.valueOf((char) i4));
        }
        List listL0 = AbstractC0728h.l0(arrayList);
        Collections.shuffle(listL0);
        String strA0 = AbstractC0728h.a0(((ArrayList) listL0).subList(0, 8), "", null, null, null, 62);
        File file = new File(this.zza.getCacheDir(), this.zzb.concat(String.valueOf(strA0)));
        zzad.zzb(file, String.valueOf(str2).getBytes(StandardCharsets.UTF_8));
        file.renameTo(new File(this.zza.getCacheDir(), this.zzb.concat(String.valueOf(str))));
    }

    @Override // com.google.android.recaptcha.internal.zzh
    public final boolean zzd(String str) {
        File file;
        try {
            File[] fileArrListFiles = this.zza.getCacheDir().listFiles();
            file = null;
            if (fileArrListFiles != null) {
                int length = fileArrListFiles.length;
                int i4 = 0;
                while (true) {
                    if (i4 >= length) {
                        break;
                    }
                    File file2 = fileArrListFiles[i4];
                    if (i.a(file2.getName(), this.zzb + str)) {
                        file = file2;
                        break;
                    }
                    i4++;
                }
            }
        } catch (Exception unused) {
        }
        return file != null;
    }
}
