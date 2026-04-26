package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.fido.zzaj;
import com.google.android.gms.internal.fido.zzak;
import com.google.android.gms.internal.fido.zzbf;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0074j extends AbstractC0076l {
    public static final Parcelable.Creator<C0074j> CREATOR = new W(8);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f1016a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f1017b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1018c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final String[] f1019d;

    public C0074j(byte[] bArr, byte[] bArr2, byte[] bArr3, String[] strArr) {
        com.google.android.gms.common.internal.F.g(bArr);
        this.f1016a = bArr;
        com.google.android.gms.common.internal.F.g(bArr2);
        this.f1017b = bArr2;
        com.google.android.gms.common.internal.F.g(bArr3);
        this.f1018c = bArr3;
        com.google.android.gms.common.internal.F.g(strArr);
        this.f1019d = strArr;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0074j)) {
            return false;
        }
        C0074j c0074j = (C0074j) obj;
        return Arrays.equals(this.f1016a, c0074j.f1016a) && Arrays.equals(this.f1017b, c0074j.f1017b) && Arrays.equals(this.f1018c, c0074j.f1018c);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(Arrays.hashCode(this.f1016a)), Integer.valueOf(Arrays.hashCode(this.f1017b)), Integer.valueOf(Arrays.hashCode(this.f1018c))});
    }

    public final String toString() {
        zzaj zzajVarZza = zzak.zza(this);
        zzbf zzbfVarZzd = zzbf.zzd();
        byte[] bArr = this.f1016a;
        zzajVarZza.zzb("keyHandle", zzbfVarZzd.zze(bArr, 0, bArr.length));
        zzbf zzbfVarZzd2 = zzbf.zzd();
        byte[] bArr2 = this.f1017b;
        zzajVarZza.zzb("clientDataJSON", zzbfVarZzd2.zze(bArr2, 0, bArr2.length));
        zzbf zzbfVarZzd3 = zzbf.zzd();
        byte[] bArr3 = this.f1018c;
        zzajVarZza.zzb("attestationObject", zzbfVarZzd3.zze(bArr3, 0, bArr3.length));
        zzajVarZza.zzb("transports", Arrays.toString(this.f1019d));
        return zzajVarZza.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.c0(parcel, 2, this.f1016a, false);
        AbstractC0184a.c0(parcel, 3, this.f1017b, false);
        AbstractC0184a.c0(parcel, 4, this.f1018c, false);
        String[] strArr = this.f1019d;
        if (strArr != null) {
            int iM02 = AbstractC0184a.m0(5, parcel);
            parcel.writeStringArray(strArr);
            AbstractC0184a.n0(iM02, parcel);
        }
        AbstractC0184a.n0(iM0, parcel);
    }
}
