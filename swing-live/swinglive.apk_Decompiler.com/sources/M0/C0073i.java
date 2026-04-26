package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.fido.zzaj;
import com.google.android.gms.internal.fido.zzak;
import com.google.android.gms.internal.fido.zzbf;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.i, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0073i extends AbstractC0076l {
    public static final Parcelable.Creator<C0073i> CREATOR = new W(7);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final byte[] f1012a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final byte[] f1013b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final byte[] f1014c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final byte[] f1015d;
    public final byte[] e;

    public C0073i(byte[] bArr, byte[] bArr2, byte[] bArr3, byte[] bArr4, byte[] bArr5) {
        com.google.android.gms.common.internal.F.g(bArr);
        this.f1012a = bArr;
        com.google.android.gms.common.internal.F.g(bArr2);
        this.f1013b = bArr2;
        com.google.android.gms.common.internal.F.g(bArr3);
        this.f1014c = bArr3;
        com.google.android.gms.common.internal.F.g(bArr4);
        this.f1015d = bArr4;
        this.e = bArr5;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0073i)) {
            return false;
        }
        C0073i c0073i = (C0073i) obj;
        return Arrays.equals(this.f1012a, c0073i.f1012a) && Arrays.equals(this.f1013b, c0073i.f1013b) && Arrays.equals(this.f1014c, c0073i.f1014c) && Arrays.equals(this.f1015d, c0073i.f1015d) && Arrays.equals(this.e, c0073i.e);
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(Arrays.hashCode(this.f1012a)), Integer.valueOf(Arrays.hashCode(this.f1013b)), Integer.valueOf(Arrays.hashCode(this.f1014c)), Integer.valueOf(Arrays.hashCode(this.f1015d)), Integer.valueOf(Arrays.hashCode(this.e))});
    }

    public final String toString() {
        zzaj zzajVarZza = zzak.zza(this);
        zzbf zzbfVarZzd = zzbf.zzd();
        byte[] bArr = this.f1012a;
        zzajVarZza.zzb("keyHandle", zzbfVarZzd.zze(bArr, 0, bArr.length));
        zzbf zzbfVarZzd2 = zzbf.zzd();
        byte[] bArr2 = this.f1013b;
        zzajVarZza.zzb("clientDataJSON", zzbfVarZzd2.zze(bArr2, 0, bArr2.length));
        zzbf zzbfVarZzd3 = zzbf.zzd();
        byte[] bArr3 = this.f1014c;
        zzajVarZza.zzb("authenticatorData", zzbfVarZzd3.zze(bArr3, 0, bArr3.length));
        zzbf zzbfVarZzd4 = zzbf.zzd();
        byte[] bArr4 = this.f1015d;
        zzajVarZza.zzb("signature", zzbfVarZzd4.zze(bArr4, 0, bArr4.length));
        byte[] bArr5 = this.e;
        if (bArr5 != null) {
            zzajVarZza.zzb("userHandle", zzbf.zzd().zze(bArr5, 0, bArr5.length));
        }
        return zzajVarZza.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.c0(parcel, 2, this.f1012a, false);
        AbstractC0184a.c0(parcel, 3, this.f1013b, false);
        AbstractC0184a.c0(parcel, 4, this.f1014c, false);
        AbstractC0184a.c0(parcel, 5, this.f1015d, false);
        AbstractC0184a.c0(parcel, 6, this.e, false);
        AbstractC0184a.n0(iM0, parcel);
    }
}
