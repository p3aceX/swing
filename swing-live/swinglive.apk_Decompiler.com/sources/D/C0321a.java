package d;

import O.O;
import android.content.Intent;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: renamed from: d.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0321a implements Parcelable {
    public static final Parcelable.Creator<C0321a> CREATOR = new O(19);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final int f3875a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Intent f3876b;

    public C0321a(int i4, Intent intent) {
        this.f3875a = i4;
        this.f3876b = intent;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    public final String toString() {
        StringBuilder sb = new StringBuilder("ActivityResult{resultCode=");
        int i4 = this.f3875a;
        sb.append(i4 != -1 ? i4 != 0 ? String.valueOf(i4) : "RESULT_CANCELED" : "RESULT_OK");
        sb.append(", data=");
        sb.append(this.f3876b);
        sb.append('}');
        return sb.toString();
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        parcel.writeInt(this.f3875a);
        Intent intent = this.f3876b;
        parcel.writeInt(intent == null ? 0 : 1);
        if (intent != null) {
            intent.writeToParcel(parcel, i4);
        }
    }

    public C0321a(Parcel parcel) {
        this.f3875a = parcel.readInt();
        this.f3876b = parcel.readInt() == 0 ? null : (Intent) Intent.CREATOR.createFromParcel(parcel);
    }
}
