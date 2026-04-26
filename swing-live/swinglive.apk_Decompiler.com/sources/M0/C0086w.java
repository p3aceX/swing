package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: renamed from: M0.w, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0086w extends A0.a {
    public static final Parcelable.Creator<C0086w> CREATOR = new D0.c(13);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final boolean f1039a;

    public C0086w(boolean z4) {
        this.f1039a = z4;
    }

    public final boolean equals(Object obj) {
        if (obj instanceof C0086w) {
            return this.f1039a == ((C0086w) obj).f1039a;
        }
        return false;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Boolean.valueOf(this.f1039a)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f1039a ? 1 : 0);
        AbstractC0184a.n0(iM0, parcel);
    }
}
