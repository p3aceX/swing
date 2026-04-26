package O;

import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class J implements Parcelable {
    public static final Parcelable.Creator<J> CREATOR = new M0.W(29);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public String f1218a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f1219b;

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeString(this.f1218a);
        parcel.writeInt(this.f1219b);
    }
}
