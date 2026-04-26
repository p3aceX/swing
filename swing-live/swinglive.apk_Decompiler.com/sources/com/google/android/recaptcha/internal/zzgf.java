package com.google.android.recaptcha.internal;

import B1.a;
import com.google.android.recaptcha.internal.zzge;
import com.google.android.recaptcha.internal.zzgf;
import com.google.crypto.tink.shaded.protobuf.S;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/* JADX INFO: loaded from: classes.dex */
public abstract class zzgf<MessageType extends zzgf<MessageType, BuilderType>, BuilderType extends zzge<MessageType, BuilderType>> implements zzke {
    protected int zza = 0;

    /* JADX WARN: Multi-variable type inference failed */
    public static void zzc(Iterable iterable, List list) {
        byte[] bArr = zzjc.zzd;
        iterable.getClass();
        if (iterable instanceof zzjm) {
            List listZzh = ((zzjm) iterable).zzh();
            zzjm zzjmVar = (zzjm) list;
            int size = list.size();
            for (Object obj : listZzh) {
                if (obj == null) {
                    String strL = a.l("Element at index ", zzjmVar.size() - size, " is null.");
                    int size2 = zzjmVar.size();
                    while (true) {
                        size2--;
                        if (size2 < size) {
                            throw new NullPointerException(strL);
                        }
                        zzjmVar.remove(size2);
                    }
                } else if (obj instanceof zzgw) {
                    zzjmVar.zzi((zzgw) obj);
                } else {
                    zzjmVar.add((String) obj);
                }
            }
            return;
        }
        if (iterable instanceof zzkm) {
            list.addAll(iterable);
            return;
        }
        if (list instanceof ArrayList) {
            ((ArrayList) list).ensureCapacity(iterable.size() + list.size());
        }
        int size3 = list.size();
        for (Object obj2 : iterable) {
            if (obj2 == null) {
                String strL2 = a.l("Element at index ", list.size() - size3, " is null.");
                int size4 = list.size();
                while (true) {
                    size4--;
                    if (size4 < size3) {
                        throw new NullPointerException(strL2);
                    }
                    list.remove(size4);
                }
            } else {
                list.add(obj2);
            }
        }
    }

    public int zza(zzkr zzkrVar) {
        throw null;
    }

    @Override // com.google.android.recaptcha.internal.zzke
    public final zzgw zzb() {
        try {
            int iZzn = zzn();
            zzgw zzgwVar = zzgw.zzb;
            byte[] bArr = new byte[iZzn];
            zzhh zzhhVarZzA = zzhh.zzA(bArr, 0, iZzn);
            zze(zzhhVarZzA);
            zzhhVarZzA.zzB();
            return new zzgt(bArr);
        } catch (IOException e) {
            throw new RuntimeException(S.g("Serializing ", getClass().getName(), " to a ByteString threw an IOException (should never happen)."), e);
        }
    }

    public final byte[] zzd() {
        try {
            int iZzn = zzn();
            byte[] bArr = new byte[iZzn];
            zzhh zzhhVarZzA = zzhh.zzA(bArr, 0, iZzn);
            zze(zzhhVarZzA);
            zzhhVarZzA.zzB();
            return bArr;
        } catch (IOException e) {
            throw new RuntimeException(S.g("Serializing ", getClass().getName(), " to a byte array threw an IOException (should never happen)."), e);
        }
    }
}
