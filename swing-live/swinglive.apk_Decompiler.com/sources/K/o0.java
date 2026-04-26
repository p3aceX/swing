package k;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class o0 extends H.c {
    public static final Parcelable.Creator<o0> CREATOR = new H.b(3);

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f5421c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f5422d;

    public o0(Parcel parcel, ClassLoader classLoader) {
        super(parcel, classLoader);
        this.f5421c = parcel.readInt();
        this.f5422d = parcel.readInt() != 0;
    }

    @Override // H.c, android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        super.writeToParcel(parcel, i4);
        parcel.writeInt(this.f5421c);
        parcel.writeInt(this.f5422d ? 1 : 0);
    }
}
