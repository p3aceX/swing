package M0;

import a.AbstractC0184a;
import android.os.Parcel;
import android.os.Parcelable;
import java.util.Arrays;

/* JADX INFO: loaded from: classes.dex */
public final class O extends A0.a {
    public static final Parcelable.Creator<O> CREATOR = new W(1);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f973a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final short f974b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final short f975c;

    public O(int i4, short s4, short s5) {
        this.f973a = i4;
        this.f974b = s4;
        this.f975c = s5;
    }

    public final boolean equals(Object obj) {
        if (!(obj instanceof O)) {
            return false;
        }
        O o4 = (O) obj;
        return this.f973a == o4.f973a && this.f974b == o4.f974b && this.f975c == o4.f975c;
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{Integer.valueOf(this.f973a), Short.valueOf(this.f974b), Short.valueOf(this.f975c)});
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        int iM0 = AbstractC0184a.m0(20293, parcel);
        AbstractC0184a.o0(parcel, 1, 4);
        parcel.writeInt(this.f973a);
        AbstractC0184a.o0(parcel, 2, 4);
        parcel.writeInt(this.f974b);
        AbstractC0184a.o0(parcel, 3, 4);
        parcel.writeInt(this.f975c);
        AbstractC0184a.n0(iM0, parcel);
    }
}
