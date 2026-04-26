package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import com.google.android.gms.internal.fido.zzaj;
import com.google.android.gms.internal.fido.zzak;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.k, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0075k extends AbstractC0076l {
    public static final Parcelable.Creator<C0075k> CREATOR = new W(9);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final EnumC0084u f1020a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final String f1021b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f1022c;

    public C0075k(int i4, String str, int i5) {
        try {
            this.f1020a = EnumC0084u.a(i4);
            this.f1021b = str;
            this.f1022c = i5;
        } catch (C0083t e) {
            throw new IllegalArgumentException(e);
        }
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof C0075k)) {
            return false;
        }
        C0075k c0075k = (C0075k) obj;
        return com.google.android.gms.common.internal.F.j(this.f1020a, c0075k.f1020a) && com.google.android.gms.common.internal.F.j(this.f1021b, c0075k.f1021b) && com.google.android.gms.common.internal.F.j(Integer.valueOf(this.f1022c), Integer.valueOf(c0075k.f1022c));
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f1020a, this.f1021b, Integer.valueOf(this.f1022c)});
    }

    public final String toString() {
        zzaj zzajVarZza = zzak.zza(this);
        zzajVarZza.zza("errorCode", this.f1020a.f1037a);
        String str = this.f1021b;
        if (str != null) {
            zzajVarZza.zzb("errorMessage", str);
        }
        return zzajVarZza.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        int i5 = this.f1020a.f1037a;
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(i5);
        AbstractC0184a.i0(parcel, 3, this.f1021b, false);
        AbstractC0184a.o0(parcel, 4, 4);
        parcel.writeInt(this.f1022c);
        AbstractC0184a.n0(iM0, parcel);
    }
}
