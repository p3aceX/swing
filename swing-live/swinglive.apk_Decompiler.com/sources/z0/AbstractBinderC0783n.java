package z0;

import android.os.Parcel;
import android.os.RemoteException;
import android.util.Log;
import com.google.android.gms.common.internal.D;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.internal.common.zzb;
import com.google.android.gms.internal.common.zzc;
import java.io.UnsupportedEncodingException;
import java.util.Arrays;

/* JADX INFO: renamed from: z0.n, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public abstract class AbstractBinderC0783n extends zzb implements D {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f6977a;

    public AbstractBinderC0783n(byte[] bArr) {
        super("com.google.android.gms.common.internal.ICertData");
        F.b(bArr.length == 25);
        this.f6977a = Arrays.hashCode(bArr);
    }

    public static byte[] a(String str) {
        try {
            return str.getBytes("ISO-8859-1");
        } catch (UnsupportedEncodingException e) {
            throw new AssertionError(e);
        }
    }

    public abstract byte[] c();

    public final boolean equals(Object obj) {
        if (obj != null && (obj instanceof D)) {
            try {
                D d5 = (D) obj;
                if (((AbstractBinderC0783n) d5).f6977a == this.f6977a) {
                    return Arrays.equals(c(), new I0.a(((AbstractBinderC0783n) d5).c()).f748a);
                }
            } catch (RemoteException e) {
                Log.e("GoogleCertificates", "Failed to get Google certificates from remote", e);
            }
        }
        return false;
    }

    public final int hashCode() {
        return this.f6977a;
    }

    @Override // com.google.android.gms.internal.common.zzb
    public final boolean zza(int i4, Parcel parcel, Parcel parcel2, int i5) {
        if (i4 == 1) {
            I0.a aVar = new I0.a(c());
            parcel2.writeNoException();
            zzc.zze(parcel2, aVar);
            return true;
        }
        if (i4 != 2) {
            return false;
        }
        parcel2.writeNoException();
        parcel2.writeInt(this.f6977a);
        return true;
    }
}
