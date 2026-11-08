package com.liquidhive.openair

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.view.KeyEvent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class OpenAirWidgetProvider : AppWidgetProvider() {
    companion object {
        const val ACTION_PLAY = "com.liquidhive.openair.widget.PLAY"
        const val ACTION_NEXT = "com.liquidhive.openair.widget.NEXT"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.openair_widget)
            val prefs = HomeWidgetPlugin.getData(context)
            val title = prefs.getString("title", "OpenAir") ?: "OpenAir"
            val author = prefs.getString("author", "Not playing") ?: "Not playing"
            views.setTextViewText(R.id.widget_title, title)
            views.setTextViewText(R.id.widget_author, author)

            // Play button
            val playIntent = Intent(context, OpenAirWidgetProvider::class.java).apply {
                action = ACTION_PLAY
            }
            val playPending = PendingIntent.getBroadcast(
                context, 0, playIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_play, playPending)

            // Next button
            val nextIntent = Intent(context, OpenAirWidgetProvider::class.java).apply {
                action = ACTION_NEXT
            }
            val nextPending = PendingIntent.getBroadcast(
                context, 1, nextIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_next, nextPending)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_PLAY -> sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
            ACTION_NEXT -> sendMediaButton(context, KeyEvent.KEYCODE_MEDIA_NEXT)
        }
    }

    private fun sendMediaButton(context: Context, keyCode: Int) {
        val down = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            setPackage(context.packageName)
            putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_DOWN, keyCode))
        }
        val up = Intent(Intent.ACTION_MEDIA_BUTTON).apply {
            setPackage(context.packageName)
            putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(KeyEvent.ACTION_UP, keyCode))
        }
        context.sendBroadcast(down)
        context.sendBroadcast(up)
    }
}