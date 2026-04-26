package androidx.core.app;

import android.app.PendingIntent;
import android.os.Parcel;
import android.text.TextUtils;
import androidx.core.graphics.drawable.IconCompat;
import d0.AbstractC0322a;
import d0.C0323b;
import d0.InterfaceC0324c;

/* JADX INFO: loaded from: classes.dex */
public class RemoteActionCompatParcelizer {
    public static RemoteActionCompat read(AbstractC0322a abstractC0322a) {
        RemoteActionCompat remoteActionCompat = new RemoteActionCompat();
        InterfaceC0324c interfaceC0324cG = remoteActionCompat.f2852a;
        boolean z4 = true;
        if (abstractC0322a.e(1)) {
            interfaceC0324cG = abstractC0322a.g();
        }
        remoteActionCompat.f2852a = (IconCompat) interfaceC0324cG;
        CharSequence charSequence = remoteActionCompat.f2853b;
        if (abstractC0322a.e(2)) {
            charSequence = (CharSequence) TextUtils.CHAR_SEQUENCE_CREATOR.createFromParcel(((C0323b) abstractC0322a).e);
        }
        remoteActionCompat.f2853b = charSequence;
        CharSequence charSequence2 = remoteActionCompat.f2854c;
        if (abstractC0322a.e(3)) {
            charSequence2 = (CharSequence) TextUtils.CHAR_SEQUENCE_CREATOR.createFromParcel(((C0323b) abstractC0322a).e);
        }
        remoteActionCompat.f2854c = charSequence2;
        remoteActionCompat.f2855d = (PendingIntent) abstractC0322a.f(remoteActionCompat.f2855d, 4);
        boolean z5 = remoteActionCompat.e;
        if (abstractC0322a.e(5)) {
            z5 = ((C0323b) abstractC0322a).e.readInt() != 0;
        }
        remoteActionCompat.e = z5;
        boolean z6 = remoteActionCompat.f2856f;
        if (!abstractC0322a.e(6)) {
            z4 = z6;
        } else if (((C0323b) abstractC0322a).e.readInt() == 0) {
            z4 = false;
        }
        remoteActionCompat.f2856f = z4;
        return remoteActionCompat;
    }

    public static void write(RemoteActionCompat remoteActionCompat, AbstractC0322a abstractC0322a) {
        abstractC0322a.getClass();
        IconCompat iconCompat = remoteActionCompat.f2852a;
        abstractC0322a.h(1);
        abstractC0322a.i(iconCompat);
        CharSequence charSequence = remoteActionCompat.f2853b;
        abstractC0322a.h(2);
        Parcel parcel = ((C0323b) abstractC0322a).e;
        TextUtils.writeToParcel(charSequence, parcel, 0);
        CharSequence charSequence2 = remoteActionCompat.f2854c;
        abstractC0322a.h(3);
        TextUtils.writeToParcel(charSequence2, parcel, 0);
        PendingIntent pendingIntent = remoteActionCompat.f2855d;
        abstractC0322a.h(4);
        parcel.writeParcelable(pendingIntent, 0);
        boolean z4 = remoteActionCompat.e;
        abstractC0322a.h(5);
        parcel.writeInt(z4 ? 1 : 0);
        boolean z5 = remoteActionCompat.f2856f;
        abstractC0322a.h(6);
        parcel.writeInt(z5 ? 1 : 0);
    }
}
