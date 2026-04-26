package d;

import J3.i;
import O.O;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Parcel;
import android.os.Parcelable;

/* JADX INFO: loaded from: classes.dex */
public final class d implements Parcelable {
    public static final Parcelable.Creator<d> CREATOR = new O(20);

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final IntentSender f3879a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Intent f3880b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final int f3881c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f3882d;

    public d(IntentSender intentSender, Intent intent, int i4, int i5) {
        this.f3879a = intentSender;
        this.f3880b = intent;
        this.f3881c = i4;
        this.f3882d = i5;
    }

    @Override // android.os.Parcelable
    public final int describeContents() {
        return 0;
    }

    @Override // android.os.Parcelable
    public final void writeToParcel(Parcel parcel, int i4) {
        i.e(parcel, "dest");
        parcel.writeParcelable(this.f3879a, i4);
        parcel.writeParcelable(this.f3880b, i4);
        parcel.writeInt(this.f3881c);
        parcel.writeInt(this.f3882d);
    }
}
