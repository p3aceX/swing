package N0;

import M0.W;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public enum a implements Parcelable {
    /* JADX INFO: Fake field, exist only in values array */
    ABSENT(0),
    STRING(1),
    /* JADX INFO: Fake field, exist only in values array */
    OBJECT(2);

    public static final Parcelable.Creator<a> CREATOR = new W(19);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f1107a;

    a(int i4) {
        this.f1107a = i4;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f1107a);
    }
}
